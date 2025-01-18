import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import compression from 'compression';
import { createProxyMiddleware } from 'http-proxy-middleware';
import dotenv from 'dotenv';
import swaggerUi from 'swagger-ui-express';
import swaggerJsdoc from 'swagger-jsdoc';
import { logger } from './utils/logger';
import { errorHandler } from './middleware/errorHandler';
import { rateLimiter } from './middleware/rateLimiter';
import { authMiddleware } from './middleware/auth';
import { redisClient } from './config/redis';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 8080;

// Swagger configuration
const swaggerOptions = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Scalable App API Gateway',
      version: '1.0.0',
      description: 'API Gateway for scalable microservices architecture',
    },
    servers: [
      {
        url: `http://localhost:${PORT}`,
        description: 'Development server',
      },
    ],
  },
  apis: ['./src/routes/*.ts'],
};

const swaggerSpec = swaggerJsdoc(swaggerOptions);

// Middleware
app.use(helmet());
app.use(cors());
app.use(compression());
app.use(morgan('combined', { stream: { write: message => logger.info(message.trim()) } }));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Rate limiting
app.use(rateLimiter);

// API Documentation
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

// Health check endpoints
app.get('/health', (req, res) => {
  res.status(200).json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development',
    service: 'api-gateway'
  });
});

app.get('/ready', async (req, res) => {
  try {
    // Check Redis connection
    await redisClient.ping();
    
    res.status(200).json({ 
      status: 'ready',
      timestamp: new Date().toISOString(),
      services: {
        redis: 'connected'
      }
    });
  } catch (error) {
    logger.error('Readiness check failed:', error);
    res.status(503).json({ 
      status: 'not ready',
      timestamp: new Date().toISOString(),
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

// API Routes with proxy
const backendServiceUrl = process.env.BACKEND_SERVICE_URL || 'http://backend-service:3000';

// Protected routes (require authentication)
app.use('/api/auth', authMiddleware, createProxyMiddleware({
  target: backendServiceUrl,
  changeOrigin: true,
  pathRewrite: {
    '^/api': '/api'
  },
  onError: (err, req, res) => {
    logger.error('Proxy error:', err);
    res.status(503).json({ error: 'Service temporarily unavailable' });
  }
}));

app.use('/api/users', authMiddleware, createProxyMiddleware({
  target: backendServiceUrl,
  changeOrigin: true,
  pathRewrite: {
    '^/api': '/api'
  },
  onError: (err, req, res) => {
    logger.error('Proxy error:', err);
    res.status(503).json({ error: 'Service temporarily unavailable' });
  }
}));

app.use('/api/dashboard', authMiddleware, createProxyMiddleware({
  target: backendServiceUrl,
  changeOrigin: true,
  pathRewrite: {
    '^/api': '/api'
  },
  onError: (err, req, res) => {
    logger.error('Proxy error:', err);
    res.status(503).json({ error: 'Service temporarily unavailable' });
  }
}));

// Public routes (no authentication required)
app.use('/api/public', createProxyMiddleware({
  target: backendServiceUrl,
  changeOrigin: true,
  pathRewrite: {
    '^/api/public': '/api/public'
  },
  onError: (err, req, res) => {
    logger.error('Proxy error:', err);
    res.status(503).json({ error: 'Service temporarily unavailable' });
  }
}));

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({ 
    error: 'Not Found', 
    message: `Route ${req.originalUrl} not found` 
  });
});

// Error handler
app.use(errorHandler);

// Graceful shutdown
process.on('SIGTERM', async () => {
  logger.info('SIGTERM received, shutting down gracefully');
  await redisClient.quit();
  process.exit(0);
});

process.on('SIGINT', async () => {
  logger.info('SIGINT received, shutting down gracefully');
  await redisClient.quit();
  process.exit(0);
});

// Start server
app.listen(PORT, () => {
  logger.info(`API Gateway running on port ${PORT}`);
  logger.info(`API documentation available at http://localhost:${PORT}/api-docs`);
});

export default app;
