import React from 'react';
import { createBrowserRouter, RouterProvider } from 'react-router-dom';
import Signup from './Signup';
import Login from './Login';
import Home from './Home';
import Meal from './Meal';

function App() {
  const router = createBrowserRouter([
    {
      path: '/',
      element: <Login />
    },
    {
      path: '/signup',
      element: <Signup />
    },
    {
      path: '/home',
      element: <Home />
    },
    {
      path: '/meal',
      element: <Meal />
    }
  ]);

  return (
    <>
      <RouterProvider router={router} />
    </>
  );
}

export default App;