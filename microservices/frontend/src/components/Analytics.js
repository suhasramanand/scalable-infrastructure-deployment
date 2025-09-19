import React from 'react';
import { useQuery } from 'react-query';
import {
  Grid,
  Card,
  CardContent,
  Typography,
  CircularProgress,
  Alert,
  Box
} from '@mui/material';
import { useApi } from '../hooks/useApi';

const Analytics = () => {
  const api = useApi();
  
  const { data: analytics, isLoading, error } = useQuery(
    'analytics',
    () => api.get('/api/analytics'),
    {
      refetchInterval: 30000, // Refetch every 30 seconds
    }
  );

  if (isLoading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="400px">
        <CircularProgress />
      </Box>
    );
  }

  if (error) {
    return (
      <Alert severity="error">
        Failed to load analytics: {error.message}
      </Alert>
    );
  }

  return (
    <div>
      <Typography variant="h4" gutterBottom>
        Analytics Dashboard
      </Typography>
      
      <Grid container spacing={3}>
        <Grid item xs={12}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                API Requests Over Time
              </Typography>
              <Box height={300} display="flex" alignItems="center" justifyContent="center">
                <Typography variant="body1" color="text.secondary">
                  Chart visualization would be implemented with a charting library like Chart.js or Recharts
                </Typography>
              </Box>
            </CardContent>
          </Card>
        </Grid>
        
        <Grid item xs={12} md={6}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                Response Time (ms)
              </Typography>
              <Typography variant="h4" color="primary">
                {analytics?.data?.avgResponseTime || 0}
              </Typography>
            </CardContent>
          </Card>
        </Grid>
        
        <Grid item xs={12} md={6}>
          <Card>
            <CardContent>
              <Typography variant="h6" gutterBottom>
                Error Rate (%)
              </Typography>
              <Typography variant="h4" color={analytics?.data?.errorRate > 5 ? "error" : "success"}>
                {analytics?.data?.errorRate || 0}%
              </Typography>
            </CardContent>
          </Card>
        </Grid>
      </Grid>
    </div>
  );
};

export default Analytics;
