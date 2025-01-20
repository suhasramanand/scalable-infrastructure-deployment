import { Request, Response, NextFunction } from 'express';
import { RateLimiterRedis } from 'rate-limiter-flexible';
import { redisClient } from '../config/redis';
import { logger } from '../utils/logger';

const rateLimiter = new RateLimiterRedis({
  storeClient: redisClient,
  keyPrefix: 'api_gateway',
  points: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100'),
  duration: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000') / 1000, // Convert to seconds
  blockDuration: 60, // Block for 60 seconds
});

export const rateLimiterMiddleware = async (
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    await rateLimiter.consume(req.ip);
    next();
  } catch (rejRes) {
    logger.warn(`Rate limit exceeded for IP: ${req.ip}`);
    res.status(429).json({
      error: 'Too Many Requests',
      message: 'Rate limit exceeded. Please try again later.',
      retryAfter: Math.round(rejRes.msBeforeNext / 1000) || 1,
    });
  }
};

export { rateLimiter };
