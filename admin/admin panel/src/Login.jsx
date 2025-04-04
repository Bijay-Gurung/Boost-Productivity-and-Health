import React, {useState} from "react";
import {Link, useNavigate} from 'react-router-dom';
import axios from 'axios';
import "./login.css";

export default function Login(){
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState(''); 
    const navigate = useNavigate();

    const handleSubmit = async (e) => {
        e.preventDefault();
        
        try {
            const response = await axios.post('http://localhost:4000/adminLogin', { email, password });
            if (response.data.message === "Login successful") {
                console.log('Login successful:', response.data);
                navigate('/home', {
                    state: {
                        adminName: response.data.admin.adminName, 
                        email: response.data.admin.email 
                    } 
                });
            }
        } catch (error) {
            if (error.response) {
                console.error('Server responded with error:', error.response.data);
                alert(error.response.data.message || 'Login failed');
            } else {
                console.error('Network/Request error:', error.message);
                alert('Network error. Please try again.');
            }
        }
    };

    return(
        <>
        <div className="LoginForm">
            <form onSubmit={handleSubmit}>
                <h1>Login</h1>
                <div className="Field">
                    <input type="email" id="adminEmail" name="adminEmail" placeholder="Email" onChange={(e) => setEmail(e.target.value)} required />
                    <br />
                    <input type="password" id="adminPassword" name="adminPassword" placeholder="Password" onChange={(e) => setPassword(e.target.value)} required />
                    <br />
                    <div className="dha">
                        <p>Don't have an account</p>
                        <Link to="/signup" className="signup">Signup</Link>
                    </div>
                    <br />
                    <button type="submit">Login</button>
                </div>
            </form>
        </div>
        </>
    );
}