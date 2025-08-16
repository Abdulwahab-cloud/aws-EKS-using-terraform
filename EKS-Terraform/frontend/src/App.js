import React, { useState, useEffect } from 'react';
import {
  Container,
  Typography,
  TextField,
  Button,
  List,
  ListItem,
  ListItemText,
  Paper,
  createTheme,
  ThemeProvider,
  CssBaseline,
} from '@mui/material';
import axios from 'axios';


const theme = createTheme({
  palette: {
    mode: 'dark',
    primary: {
      main: '#3C873A', 
    },
    background: {
      default: '#1E1E1E', 
      paper: '#2C2C2C',  
    },
    text: {
      primary: '#B0B0B0',
    },
  },
  typography: {
    fontFamily: "'Roboto Mono', monospace", 
  },
});

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:5000';

function App() {
  const [users, setUsers] = useState([]);
  const [name, setName] = useState('');

  const fetchUsers = async () => {
    try {
      const res = await axios.get(`${API_URL}/users`);
      setUsers(res.data);
    } catch (err) {
      console.error(err);
    }
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  const handleAddUser = async () => {
    if (!name.trim()) return;
    try {
      await axios.post(`${API_URL}/users`, { name });
      setName('');
      fetchUsers();
    } catch (err) {
      console.error(err);
    }
  };

  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Container maxWidth="sm" style={{ marginTop: '3rem' }}>
        <Typography variant="h3" align="center" gutterBottom sx={{ fontWeight: 'bold', color: '#3C873A' }}>
          Hi i'm Abdulwahab this simple User Manager WebApp Deployed using EKS
        </Typography>

        <Paper sx={{ padding: 3, marginBottom: 4, backgroundColor: '#2C2C2C' }} elevation={3}>
          <TextField
            fullWidth
            label="Enter user name"
            variant="filled"
            value={name}
            onChange={(e) => setName(e.target.value)}
            onKeyDown={(e) => e.key === 'Enter' && handleAddUser()}
            InputLabelProps={{ style: { color: '#3C873A' } }}
            InputProps={{ style: { color: '#B0B0B0', backgroundColor: '#1E1E1E' } }}
          />
          <Button
            variant="contained"
            color="primary"
            onClick={handleAddUser}
            fullWidth
            sx={{ marginTop: 2, fontWeight: 'bold' }}
          >
            Add User
          </Button>
        </Paper>

        <Paper sx={{ padding: 3, backgroundColor: '#2C2C2C' }} elevation={3}>
          <Typography variant="h5" gutterBottom sx={{ color: '#3C873A' }}>
            Users List
          </Typography>
          <List>
            {users.length === 0 && (
              <Typography sx={{ color: '#888', fontStyle: 'italic' }}>No users added yet.</Typography>
            )}
            {users.map((user) => (
              <ListItem key={user.id} divider sx={{ color: '#B0B0B0' }}>
                <ListItemText primary={user.name} />
              </ListItem>
            ))}
          </List>
        </Paper>
      </Container>
    </ThemeProvider>
  );
}

export default App;
