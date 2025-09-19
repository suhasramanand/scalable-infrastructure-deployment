import { useCallback } from 'react';
import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:8080';

export const useApi = () => {
  const api = axios.create({
    baseURL: API_BASE_URL,
    timeout: 10000,
    headers: {
      'Content-Type': 'application/json',
    },
  });

  // Request interceptor to add auth token
  api.interceptors.request.use(
    (config) => {
      const token = localStorage.getItem('authToken');
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }
      return config;
    },
    (error) => {
      return Promise.reject(error);
    }
  );

  // Response interceptor to handle common errors
  api.interceptors.response.use(
    (response) => response,
    (error) => {
      if (error.response?.status === 401) {
        localStorage.removeItem('authToken');
        window.location.href = '/login';
      }
      return Promise.reject(error);
    }
  );

  const get = useCallback(async (url, config = {}) => {
    const response = await api.get(url, config);
    return response.data;
  }, [api]);

  const post = useCallback(async (url, data, config = {}) => {
    const response = await api.post(url, data, config);
    return response.data;
  }, [api]);

  const put = useCallback(async (url, data, config = {}) => {
    const response = await api.put(url, data, config);
    return response.data;
  }, [api]);

  const del = useCallback(async (url, config = {}) => {
    const response = await api.delete(url, config);
    return response.data;
  }, [api]);

  return {
    get,
    post,
    put,
    delete: del,
    axios: api,
  };
};
