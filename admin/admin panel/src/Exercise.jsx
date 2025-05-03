import React, { useState, useEffect } from 'react';
import "./Exercise.css";
import axios from 'axios';
import { useNavigate, useLocation } from 'react-router-dom';

function Nav({ adminName, email }) {
    const navigate = useNavigate();

    const handleLogout = () => {
        navigate('/');
    };

    return (
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
    );
}

function SideNav({ adminName, email }) {
    const navigate = useNavigate();
    const [exercises, setExercises] = useState([]);
    const [editMode, setEditMode] = useState(false);
    const [selectedExercise, setSelectedExercise] = useState(null);
    
    // Form states
    const [name, setName] = useState('');
    const [category, setCategory] = useState('');
    const [muscleGroup, setMuscleGroup] = useState('');
    const [duration, setDuration] = useState('');
    const [caloriesBurned, setCaloriesBurned] = useState('');
    const [intensity, setIntensity] = useState('');
    const [steps, setSteps] = useState('');
    const [gender, setGender] = useState('Any');
    const [image, setImage] = useState(null);

    useEffect(() => {
        fetchExercises();
    }, []);

    const fetchExercises = async () => {
        try {
            const response = await axios.get("http://localhost:4000/exercise");
            setExercises(response.data);
        } catch (err) {
            console.error("Error fetching exercises:", err);
            alert("Failed to load exercises");
        }
    };

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
        if (image) formData.append('image', image);
        formData.append('recommendedFor', JSON.stringify({
            gender,
            bmiRange: { min: 18.5, max: 24.9 },
            ageRange: { min: 18, max: 65 }
        }));

        try {
            const url = editMode && selectedExercise 
                ? `http://localhost:4000/exercise/${selectedExercise._id}`
                : 'http://localhost:4000/exercise';

            const method = editMode ? 'put' : 'post';
            
            await axios[method](url, formData, {
                headers: { 'Content-Type': 'multipart/form-data' }
            });

            resetForm();
            fetchExercises();
            alert(`Exercise ${editMode ? 'updated' : 'created'} successfully!`);
        } catch (err) {
            console.error(err);
            alert(`Error ${editMode ? 'updating' : 'creating'} exercise`);
        }
    };

    const handleEdit = (exercise) => {
        setEditMode(true);
        setSelectedExercise(exercise);
        setName(exercise.name);
        setCategory(exercise.category);
        setMuscleGroup(exercise.muscleGroup);
        setDuration(exercise.duration);
        setCaloriesBurned(exercise.caloriesBurned);
        setIntensity(exercise.intensity);
        setSteps(exercise.steps);
        setGender(exercise.recommendedFor?.gender || 'Any');
    };

    const handleDelete = async (id) => {
        if (window.confirm("Are you sure you want to delete this exercise?")) {
            try {
                await axios.delete(`http://localhost:4000/exercise/${id}`);
                fetchExercises();
                alert("Exercise deleted successfully!");
            } catch (err) {
                console.error("Error deleting exercise:", err);
                alert("Error deleting exercise");
            }
        }
    };

    const resetForm = () => {
        setEditMode(false);
        setSelectedExercise(null);
        setName('');
        setCategory('');
        setMuscleGroup('');
        setDuration('');
        setCaloriesBurned('');
        setIntensity('');
        setSteps('');
        setGender('Any');
        setImage(null);
    };

    const handleDashboard = () => {
        navigate('/home', { state: { adminName, email } });
    }

    const handleMeal = () => {
        navigate('/meal', { state: { adminName, email } });
    }

    const handleExercise = () => {
        navigate('/exercise', {state: {adminName, email}});
    }

    return (
        <div className='section'>
            <div className='sideNav'>
                <div className='features'>
                    <button className='btn dashboard' onClick={handleDashboard}>Dashboard</button>
                    <button className='btn exercise' onClick={handleExercise}>Exercise</button>
                    <button className='btn mealPlan' onClick={handleMeal}>Meal Plan</button>
                </div>
            </div>

            <div className='content'>
                <form onSubmit={handleSubmit} encType="multipart/form-data">
                    <div className="left">
                        <input type="text" value={name} placeholder="Exercise Name" 
                            onChange={(e) => setName(e.target.value)} required /><br/>
                        
                        <select value={muscleGroup} onChange={(e) => setMuscleGroup(e.target.value)} required>
                            <option value="" disabled>Select Muscle Group</option>
                            <option value="Chest">Chest</option>
                            <option value="Back">Back</option>
                            <option value="Shoulder">Shoulder</option>
                            <option value="Biceps">Biceps</option>
                            <option value="Triceps">Triceps</option>
                            <option value="Legs">Legs</option>
                            <option value="Abs">Abs</option>
                            <option value="Fullbody">Full Body</option>
                            <option value="core">Core</option>
                            <option value="lc">Legs, Core</option>
                            <option value="cls">Core, Legs, Shoulders</option>
                            <option value="lac">Legs, Arms, Core</option>
                            <option value="hlb">Hamstrings, Lower Back</option>
                            <option value="innerThigh">Inner Thighs</option>
                            <option values="ol">Obliques, Lats</option>
                            <option values="hfq">Hip Flexors, Quads</option>
                        </select><br/>

                        <input type="number" value={duration} placeholder="Duration (minutes)" 
                            onChange={(e) => setDuration(e.target.value)} required /><br/>
                        
                        <input type="number" value={caloriesBurned} placeholder="Calories Burned" 
                            onChange={(e) => setCaloriesBurned(e.target.value)} required /><br/>
                        
                        <select value={intensity} onChange={(e) => setIntensity(e.target.value)} required>
                            <option value="" disabled>Select Intensity</option>
                            <option value="Low">Low</option>
                            <option value="Medium">Medium</option>
                            <option value="High">High</option>
                            <option value="ltm">Low to Medium</option>
                            <option value="mth">Medium to High</option>
                        </select><br/>

                        <textarea rows='5' value={steps} placeholder="Steps" 
                            onChange={(e) => setSteps(e.target.value)} required /><br/>
                    </div>

                    <div className="right">
                        <input type="file" onChange={(e) => setImage(e.target.files[0])} 
                            accept="image/*" /><br/>
                        {image && <p>{image.name}</p>}

                        <select value={category} onChange={(e) => setCategory(e.target.value)} required>
                            <option value="" disabled>Select Category</option>
                            <option value="Cardio">Cardio</option>
                            <option value="Strength">Strength</option>
                            <option value="Flexibility">Flexibility</option>
                        </select><br/>

                        <select value={gender} onChange={(e) => setGender(e.target.value)} required>
                            <option value="Any">Any Gender</option>
                            <option value="Male">Male</option>
                            <option value="Female">Female</option>
                            <option value="Other">Other</option>
                        </select><br/>

                        <div className="form-buttons">
                            <button type="submit" className="submit-btn">
                                {editMode ? 'Update Exercise' : 'Create Exercise'}
                            </button>
                            {editMode && (
                                <button type="button" onClick={resetForm} className="cancel-btn">
                                    Cancel Edit
                                </button>
                            )}
                        </div>
                    </div>
                </form>
            </div>

            <div className='View'>
                <h2>Exercises</h2>
                <div className="exerciseGrid">
                    {exercises.map(exercise => (
                        <div key={exercise._id} className="exercise-card">
                            {exercise.image && (
                                <img src={`http://localhost:4000/${exercise.image}`} 
                                     alt={exercise.name} 
                                     className="exercise-image" />
                            )}
                            <div className="exerciseInfo">
                                <h3>{exercise.name}</h3>
                                <p><strong>Category:</strong> {exercise.category}</p>
                                <p><strong>Muscle Group:</strong> {exercise.muscleGroup}</p>
                                <p><strong>Duration:</strong> {exercise.duration} mins</p>
                                <p><strong>Intensity:</strong> {exercise.intensity}</p>
                                <div className="exercise-actions">
                                    <button className="edit-btn" onClick={() => handleEdit(exercise)}>
                                        Edit
                                    </button>
                                    <button className="delete-btn" onClick={() => handleDelete(exercise._id)}>
                                        Delete
                                    </button>
                                </div>
                            </div>
                        </div>
                    ))}
                </div>
            </div>
        </div>
    );
}

export default function Exercise() {
    const location = useLocation();
    const navigate = useNavigate();
    const { adminName, email } = location.state || {};

    useEffect(() => {
        if (!adminName || !email) {
            navigate('/');
        }
    }, [adminName, email, navigate]);

    return (
        <>
            <Nav adminName={adminName} email={email} />
            <SideNav adminName={adminName} email={email} />
        </>
    );
}