import { createClient, RedisClientType } from 'redis';
import { logger } from '../utils/logger';

const redisConfig = {
  url: process.env.REDIS_URL || 'redis://localhost:6379',
  socket: {
    reconnectStrategy: (retries: number) => {
      if (retries > 10) {
        logger.error('Redis connection failed after 10 retries');
        return new Error('Redis connection failed');
      }
      return Math.min(retries * 100, 3000);
    },
  },
  retryDelayOnFailover: 100,
  enableReadyCheck: false,
  maxRetriesPerRequest: null,
};

export const redisClient: RedisClientType = createClient(redisConfig);

// Redis event handlers
redisClient.on('error', (err) => {
  logger.error('Redis Client Error:', err);
});

redisClient.on('connect', () => {
  logger.info('Redis Client Connected');
});

redisClient.on('ready', () => {
  logger.info('Redis Client Ready');
});

redisClient.on('end', () => {
  logger.info('Redis Client Disconnected');
});

// Connect to Redis
const connectRedis = async (): Promise<void> => {
  try {
    await redisClient.connect();
    logger.info('Redis connection established successfully');
  } catch (error) {
    logger.error('Redis connection failed:', error);
    throw error;
  }
};

// Initialize Redis connection
connectRedis();

export default redisClient;
