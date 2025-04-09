import React, { useState } from 'react';
import "./Exercise.css";
import axios from 'axios';
import {Link, useNavigate, useLocation} from 'react-router-dom';

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
        navigate('/meal');
    }

    const handleExercise = () => {
        navigate('/exercise', {state: {adminName, email}});
    }

    const [name, setName] = useState('');
    const [category, setCategory] = useState('');
    const [muscleGroup, setMuscleGroup] = useState('');
    const [duration, setDuration] = useState('');
    const [caloriesBurned, setCaloriesBurned] = useState('');
    const [intensity, setIntensity] = useState('');
    const [steps, setSteps] = useState('');
    const [gender, setGender] = useState('');
    const [image, setImage] = useState('');


    const handleSubmit = async (e) => {
        e.preventDefault();
        
        const formData = new FormData();
        formData.append('name', name);
        formData.append('category', category);
        formData.append('muscleGroup', muscleGroup);
        formData.append('duration', duration);
        formData.append('caloriesBurned', caloriesBurned);
        formData.append('intensity', intensity);
        formData.append('steps', steps);
        formData.append('image', image);
        formData.append('gender', gender);

    
        axios.post("http://localhost:4000/exercise", formData, {
            headers: {
                'Content-Type': 'multipart/form-data'
            }
        })
        .then(result => {
            console.log(result);
            alert("New Exercise has been created");
        })
        .catch(err => console.log(err));
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
                <h1>Exercise</h1>
                <form onSubmit={handleSubmit} encType="multipart/form-data">
                <div className="left">
                    <input type="text" id="name" name="name" placeholder="Exercise Name" onChange={(e) => setName(e.target.value)} required /><br/>
                    <select name="muscleGroup" id="muscleGroup" onChange={(e) => setMuscleGroup(e.target.value)} required>
                        <option value="" disabled selected>Select Muscle Group</option>
                        <option value="Chest">Chest</option>
                        <option value="Back">Back</option>
                        <option value="Shoulder">Shoulder</option>
                        <option value="Biceps">Biceps</option>
                        <option value="triceps">Triceps</option>
                        <option value="legs">Legs</option>
                        <option value="Abs">Abs</option>
                    </select>
                    <input type="number" id="duration" name="duration" placeholder="Duration" onChange={(e) => setDuration(e.target.value)} required /><br/>
                    <input type="number" id="caloriesBurned" name="caloriesBurned" placeholder="CaloriesBurned" onChange={(e) => setCaloriesBurned(e.target.value)} required /><br/>
                    
                    <select name="intensity" id="intensity" onChange={(e) => setIntensity(e.target.value)} required>
                         <option value="" disabled selected>Select Intensity Level</option>
                        <option value="low">Low</option>
                        <option value="moderate">Moderate</option>
                        <option value="high">High</option>
                    </select>

                    <textarea rows='5' cols='29' id="steps" name="steps" placeholder="Steps" onChange={(e) => setSteps(e.target.value)} required></textarea><br/>
                </div>

                <div className="right">
                    <input type="file" id="exerciseImage" name="exerciseImage" placeholder="Upload Exercise Image" onChange={(e) => setImage(e.target.files[0])} required /><br/>
                    <select name="category" id="category" onChange={(e) => setCategory(e.target.value)} required>
                        <option value="" disabled selected>Select category</option>
                        <option value="Cardio">Cardio</option>
                        <option value="Strength">Strength</option>
                    </select><br/>

                    <select name="gender" id="gender" onChange={(e) => setGender(e.target.value)} required>
                        <option value="" disabled selected>Select Gender</option>
                        <option value="Male">Male</option>
                        <option value="Female">Female</option>
                        <option value="Any">Other</option>
                    </select>

                    <button type="submit">Create</button>
                </div>
            </form>
            </div>
        </div>
    );
}

export default function Exercise(){
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