// import React, {useState} from "react";
// import {Link, useNavigate} from 'react-router-dom';
// import axios from 'axios';

export default function Login(){
    // const [name, setName] = useState('');
    // const [email, setEmail] = useState('');
    // const [password, setPassword] = useState(''); 
    // const navigate = useNavigate();

    // const handleSubmit = (e) => {
    //     e.preventDefalut();
    //     axios.post("http://localhost:4000/adminSignup", {name, email, password})
    //     .then(result => {
    //         console.log(result);
    //         navigate("/");
    //     })
    // };

    return(
        <>
        {/* <div className="LoginForm">
            <form onSubmit={handleSubmit}>
                <h1>Signup</h1>
                <div className="Field">
                    <input type="email" id="adminEmail" name="adminEmail" placeholder="Email" onChange={(e) => setEmail(e.target.value)} required />
                    <br />
                    <input type="password" id="adminPassword" name="adminPassword" placeholder="Password" onChange={(e) => setPassword(e.target.value)} required />
                    <br />
                    <div className="dha">
                        <p>Don't have an account</p>
                        <Link to="/signup">Signup</Link>
                    </div>
                    <br />
                    <button type="submit">Login</button>
                </div>
            </form>
        </div> */}
        </>
    );
}