import React, { useState } from 'react';
import "./home.css";
import {useNavigate, useLocation} from 'react-router-dom';
// import {useNavigate} from 'react-router-dom';

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

function SideNav(){
    return(
        <div className='sideNav'>
            <div className='features'>
                <button className='btn dashboard'>Dashboard</button><br/>
                <button className='btn exercise'>Exercise</button><br/>
                <button className='btn mealPlan'>Meal Plan</button><br/>
                <button className='btn settings'>Settings</button>
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
        <SideNav />
        </>
    );
}