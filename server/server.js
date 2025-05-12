require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const bodyParser = require('body-parser');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const morgan = require('morgan');

const app = express();

// Middleware
app.use(helmet());
app.use(morgan('combined'));
app.use(bodyParser.json());

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100
});
app.use(limiter);

app.use(cors({
  origin: process.env.CORS_ORIGIN || '*'
}));

// MongoDB Connection
mongoose.connect(process.env.MONGODB_URI, {
  useNewUrlParser: true,
  useUnifiedTopology: true
})
.then(() => console.log('MongoDB connected successfully'))
.catch(err => {
  console.error('MongoDB connection error:', err);
  process.exit(1);
});

const db = mongoose.connection;
db.on('error', console.error.bind(console, 'connection error:'));

// Schema and Model
const StegoSchema = new mongoose.Schema({
  password: String,
  encodedText: String,
  chatId: String, // New field
  createdAt: { type: Date, default: Date.now }
});

const StegoData = mongoose.model('StegoData', StegoSchema);
// Add this to your schema and model definitions
const ChatInfoSchema = new mongoose.Schema({
  chatName: { type: String, unique: true },
  password: String,
  chatId: { type: String, unique: true }
});

const ChatInfo = mongoose.model('ChatInfo', ChatInfoSchema);
// Routes with Input Validation
const crypto = require('crypto');

app.post('/create-chat', async (req, res) => {
  const { chatName, password } = req.body;

  if (!chatName || !password) {
    return res.status(400).json({ error: 'Missing required fields' });
  }

  try {
    const existingChat = await ChatInfo.findOne({ chatName });
    if (existingChat) {
      const isPasswordValid = await bcrypt.compare(password, existingChat.password);
      if (!isPasswordValid) {
        return res.status(401).json({ error: 'Incorrect password' });
      }
      return res.status(200).json({ chatId: existingChat.chatId });
    }

    const chatId = crypto.randomBytes(16).toString('hex');
    const hashedPassword = await bcrypt.hash(password, 10);

    const newChat = new ChatInfo({
      chatName,
      password: hashedPassword,
      chatId
    });

    await newChat.save();
    res.status(201).json({ chatId });
  } catch (error) {
    console.error('Chat creation error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});
app.post('/store', async (req, res) => {
  const { password, encodedText, chatId } = req.body;

  if (!password || !encodedText || !chatId) {
    return res.status(400).json({ error: 'Missing required fields' });
  }

  try {
    const chat = await ChatInfo.findOne({ chatId });
    if (!chat) {
      return res.status(404).json({ error: 'Chat not found' });
    }

    const isPasswordValid = await bcrypt.compare(password, chat.password);
    if (!isPasswordValid) {
      return res.status(401).json({ error: 'Incorrect password' });
    }

    const message = new StegoData({
      encodedText,
      chatId
    });
    await message.save();
    res.status(201).json({ id: message._id });
  } catch (error) {
    console.error('Store error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.post('/retrieve', async (req, res) => {
  const { chatId, password } = req.body;

  if (!chatId || !password) {
    return res.status(400).json({ error: 'Missing required fields' });
  }

  try {
    const chat = await ChatInfo.findOne({ chatId });
    if (!chat) {
      return res.status(404).json({ error: 'Chat not found' });
    }

    const isPasswordValid = await bcrypt.compare(password, chat.password);
    if (!isPasswordValid) {
      return res.status(401).json({ error: 'Incorrect password' });
    }

    const messages = await StegoData.find({ chatId })
      .sort({ createdAt: 1 })
      .select('encodedText createdAt');

    res.status(200).json({
      messages: messages.map(msg => ({
        id: msg._id,
        text: msg.encodedText,
        timestamp: msg.createdAt.toISOString()
      }))
    });
  } catch (error) {
    console.error('Retrieve error:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});