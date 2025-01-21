import express from 'express';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';
import { db } from '../config/database';
import { logger } from '../utils/logger';

const router = express.Router();

/**
 * @swagger
 * /api/auth/login:
 *   post:
 *     summary: User login
 *     tags: [Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               email:
 *                 type: string
 *               password:
 *                 type: string
 *     responses:
 *       200:
 *         description: Login successful
 *       401:
 *         description: Invalid credentials
 */
router.post('/login', async (req, res, next) => {
  try {
    const { email, password } = req.body;
    
    const user = await db('users').where({ email }).first();
    if (!user) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    
    const isValidPassword = await bcrypt.compare(password, user.password_hash);
    if (!isValidPassword) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }
    
    const token = jwt.sign(
      { userId: user.id, email: user.email },
      process.env.JWT_SECRET || 'default-secret',
      { expiresIn: '24h' }
    );
    
    logger.info(`User ${email} logged in successfully`);
    return res.json({ token, user: { id: user.id, email: user.email, name: user.name } });
  } catch (error) {
    logger.error('Error during login:', error);
    next(error);
  }
});

export default router;
