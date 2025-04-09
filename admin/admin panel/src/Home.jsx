import React, { useState } from 'react';
import "./home.css";
import {useNavigate, useLocation} from 'react-router-dom';

function Nav({adminName, email}){
    const navigate = useNavigate();

    const handleLogout = () => {
        navigate('/');
    };

    return(
        <>
        <div className='Nav'>
            <div className='userProfile'>
                <div className='adminPhoto'></div>

                <div className='adminDetails'>
                    <h3>{adminName}</h3>
                    <p className='Name'>{email}</p>
                </div>
            </div>

            <h2>Admin Panel</h2>

            <button onClick={handleLogout} className="logout">Logout</button>
        </div>
        </>
    );
}

function SideNav({ adminName, email }){
    const navigate = useNavigate();

    const handleDashboard = () => {
        navigate('/home', { state: { adminName, email } });
    }

    const handleMeal = () => {
        navigate('/meal', { state: { adminName, email } });
    }

    const handleExercise = () => {
        navigate('/exercise', {state: {adminName, email}});
    }

    return(
        <div className='section'>
            <div className='sideNav'>
                <div className='features'>
                    <button className='btn dashboard' onClick={handleDashboard}>Dashboard</button><br/>
                    <button className='btn exercise' onClick={handleExercise}>Exercise</button><br/>
                    <button className='btn mealPlan' onClick={handleMeal}>Meal Plan</button><br/>
                    <button className='btn settings' onClick={handleDashboard}>Settings</button>
                </div>
            </div>

            <div className='content'>
            <h1>Dashboard</h1>
            </div>
        </div>
    );
}

export default function Home(){
    const location = useLocation();
    const navigate = useNavigate();

    const { adminName, email } = location.state || {};

    React.useEffect(() => {
        if (!adminName || !email) {
            navigate('/');
        }
    }, [adminName, email, navigate]);

    return(
        <>
        <Nav adminName={adminName} email={email} />
        <SideNav adminName={adminName} email={email}/>
        </>
    );
}