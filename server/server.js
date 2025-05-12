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

// Routes with Input Validation
app.post('/store', async (req, res) => {
  const { password, encodedText, chatId } = req.body; // Added chatId

  if (!password || !encodedText || !chatId) {
    return res.status(400).send('Missing required fields');
  }

  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    const stegoData = new StegoData({
      password: hashedPassword,
      encodedText,
      chatId // Include chatId
    });
    await stegoData.save();
    res.status(201).send({ id: stegoData._id, chatId }); // Return chatId
  } catch (error) {
    console.error('Error storing data:', error);
    res.status(500).send('Internal server error');
  }
});

app.post('/retrieve', async (req, res) => {
  const { chatId, password } = req.body;

  if (!chatId || !password) {
    return res.status(400).send('Missing required fields');
  }

  try {
    const stegoData = await StegoData.find({ chatId: chatId });
    if (stegoData.length === 0) {
      return res.status(404).send('Chat not found');
    }

    // Verify password against at least one message
    const isMatch = stegoData.some(item => bcrypt.compareSync(password, item.password));
    if (!isMatch) {
      return res.status(401).send('Incorrect password');
    }

    // Return all messages sorted by timestamp
    const messages = stegoData
      .sort((a, b) => a.createdAt - b.createdAt)
      .map(item => ({
        id: item._id,
        text: item.encodedText,
        time: item.createdAt.toISOString()
      }));

    res.status(200).json({ messages });
  } catch (error) {
    console.error('Error retrieving chat:', error);
    res.status(500).send('Internal server error');
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});