import express from 'express';
import { db } from '../config/database';
import { logger } from '../utils/logger';

const router = express.Router();

/**
 * @swagger
 * /api/users:
 *   get:
 *     summary: Get all users
 *     tags: [Users]
 *     responses:
 *       200:
 *         description: List of users
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 users:
 *                   type: array
 *                   items:
 *                     type: object
 */
router.get('/', async (req, res, next) => {
  try {
    const users = await db('users').select('*');
    logger.info(`Retrieved ${users.length} users`);
    res.json({ users });
  } catch (error) {
    logger.error('Error fetching users:', error);
    next(error);
  }
});

/**
 * @swagger
 * /api/users/{id}:
 *   get:
 *     summary: Get user by ID
 *     tags: [Users]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: User found
 *       404:
 *         description: User not found
 */
router.get('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;
    const user = await db('users').where({ id }).first();
    
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    logger.info(`Retrieved user with ID: ${id}`);
    return res.json({ user });
  } catch (error) {
    logger.error('Error fetching user:', error);
    next(error);
  }
});

export default router;
