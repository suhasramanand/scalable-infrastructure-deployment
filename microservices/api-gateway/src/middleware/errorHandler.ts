import { Request, Response, NextFunction } from 'express';
import { logger } from '../utils/logger';

export interface AppError extends Error {
  statusCode?: number;
  isOperational?: boolean;
}

export const errorHandler = (
  err: AppError,
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  let { statusCode = 500, message } = err;

  if (err.name === 'ValidationError') {
    statusCode = 400;
    message = 'Validation Error';
  } else if (err.name === 'UnauthorizedError') {
    statusCode = 401;
    message = 'Unauthorized';
  }

  logger.error({
    error: err,
    request: {
      method: req.method,
      url: req.url,
      headers: req.headers,
      body: req.body,
    },
    statusCode,
  });

  res.status(statusCode).json({
    error: {
      message,
      status: statusCode,
      timestamp: new Date().toISOString(),
      path: req.url,
    },
  });
};
