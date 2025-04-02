import React, { useState } from 'react';
// import {useNavigate} from 'react-router-dom';

function Nav(){
    return(
        <>
        <div className='Nav'>
            <div className='userProfile'>
                <div className='adminPhoto'></div>
                <h3>Bijay Gurung</h3>
                <p className='Name'>Stha4580@gmail.com</p>
            </div>

            <h2>Admin Panel</h2>
        </div>
        </>
    );
}

function SideNav(){
    return(
        <>
        </>
    );
}

export default function Home(){
    return(
        <>
        <Nav />
        <SideNav />
        </>
    );
}