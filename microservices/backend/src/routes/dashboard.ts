import express from 'express';
import { db } from '../config/database';
import { redisClient } from '../config/redis';
import { logger } from '../utils/logger';

const router = express.Router();

/**
 * @swagger
 * /api/dashboard/stats:
 *   get:
 *     summary: Get dashboard statistics
 *     tags: [Dashboard]
 *     responses:
 *       200:
 *         description: Dashboard statistics
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 totalUsers:
 *                   type: integer
 *                 activeSessions:
 *                   type: integer
 *                 apiRequests24h:
 *                   type: integer
 *                 systemHealth:
 *                   type: string
 */
router.get('/stats', async (req, res, next) => {
  try {
    // Get total users count
    const totalUsersResult = await db('users').count('id as count').first();
    const totalUsers = parseInt(totalUsersResult?.count as string) || 0;
    
    // Get active sessions from Redis
    const activeSessions = await redisClient.scard('active_sessions') || 0;
    
    // Get API requests in last 24 hours
    const apiRequests24h = await redisClient.get('api_requests_24h') || '0';
    
    // System health check
    const systemHealth = await checkSystemHealth();
    
    const stats = {
      totalUsers,
      activeSessions,
      apiRequests24h: parseInt(apiRequests24h),
      systemHealth,
      timestamp: new Date().toISOString()
    };
    
    logger.info('Dashboard stats retrieved successfully');
    res.json(stats);
  } catch (error) {
    logger.error('Error fetching dashboard stats:', error);
    next(error);
  }
});

async function checkSystemHealth(): Promise<string> {
  try {
    // Check database connection
    await db.raw('SELECT 1');
    
    // Check Redis connection
    await redisClient.ping();
    
    return 'healthy';
  } catch (error) {
    logger.error('System health check failed:', error);
    return 'unhealthy';
  }
}

export default router;
