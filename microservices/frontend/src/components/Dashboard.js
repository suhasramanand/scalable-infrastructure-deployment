import React from 'react';
import {
  Container,
  Typography,
  Grid,
  Card,
  CardContent,
  CardActions,
  Button
} from '@mui/material';
import { useNavigate } from 'react-router-dom';

const Dashboard = () => {
  const navigate = useNavigate();

  const handleNavigation = (path) => {
    navigate(path);
  };

  return (
    <Container maxWidth="lg" sx={{ mt: 4, mb: 4 }}>
      <Typography variant="h4" component="h1" gutterBottom>
        Scalable Infrastructure Dashboard
      </Typography>
      
      <Grid container spacing={3}>
        <Grid item xs={12} sm={6} md={4}>
          <Card>
            <CardContent>
              <Typography variant="h6" component="h2">
                User Management
              </Typography>
              <Typography variant="body2" color="text.secondary">
                Manage users, roles, and permissions across the platform.
              </Typography>
            </CardContent>
            <CardActions>
              <Button 
                size="small" 
                onClick={() => handleNavigation('/users')}
              >
                Manage Users
              </Button>
            </CardActions>
          </Card>
        </Grid>
        
        <Grid item xs={12} sm={6} md={4}>
          <Card>
            <CardContent>
              <Typography variant="h6" component="h2">
                Analytics
              </Typography>
              <Typography variant="body2" color="text.secondary">
                View system performance metrics and usage analytics.
              </Typography>
            </CardContent>
            <CardActions>
              <Button 
                size="small" 
                onClick={() => handleNavigation('/analytics')}
              >
                View Analytics
              </Button>
            </CardActions>
          </Card>
        </Grid>
        
        <Grid item xs={12} sm={6} md={4}>
          <Card>
            <CardContent>
              <Typography variant="h6" component="h2">
                System Health
              </Typography>
              <Typography variant="body2" color="text.secondary">
                Monitor system health and infrastructure status.
              </Typography>
            </CardContent>
            <CardActions>
              <Button size="small">
                View Status
              </Button>
            </CardActions>
          </Card>
        </Grid>
      </Grid>
    </Container>
  );
};

export default Dashboard;
