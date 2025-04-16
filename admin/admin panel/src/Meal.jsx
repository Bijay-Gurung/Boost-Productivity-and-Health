import React, { useState, useEffect } from 'react';
import "./meal.css";
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

function SideNav({ adminName, email }) {
    const navigate = useNavigate();
    const [meals, setMeals] = useState([]);
    const [editMode, setEditMode] = useState(false);
    const [selectedMeal, setSelectedMeal] = useState(null);

    const [recipe, setRecipe] = useState('');
    const [author, setAuthor] = useState('');
    const [date, setDate] = useState('');
    const [cookingTime, setCookingTime] = useState('');
    const [calories, setCalories] = useState('');
    const [carbs, setCarbs] = useState('');
    const [protein, setProtein] = useState('');
    const [fat, setFat] = useState('');
    const [nutInfo, setNutInfo] = useState('');
    const [ingredient, setIngredient] = useState('');
    const [process, setProcess] = useState('');
    const [image, setImage] = useState(null);
    const [details, setDetails] = useState('');
    const [category, setCategory] = useState('Breakfast');
    const [isVegan, setIsVegan] = useState(false);

    useEffect(() => {
        fetchMeals();
    }, []);

    const fetchMeals = async () => {
        try {
            const response = await axios.get("http://localhost:4000/meal");
            setMeals(response.data);
        } catch (err) {
            console.error("Error fetching meals:", err);
            alert("Failed to load meals");
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        
        const formData = new FormData();
        formData.append('recipe', recipe);
        formData.append('author', author);
        formData.append('date', date);
        formData.append('cookingTime', cookingTime);
        formData.append('calories', calories);
        formData.append('carbs', carbs);
        formData.append('protein', protein);
        formData.append('fat', fat);
        formData.append('nutInfo', nutInfo);
        formData.append('ingredient', ingredient);
        formData.append('process', process);
        if (image) formData.append('image', image);
        formData.append('details', details);
        formData.append('category', category);
        formData.append('isVegan', isVegan);

        try {
            const url = editMode && selectedMeal 
                ? `http://localhost:4000/meal/${selectedMeal._id}`
                : 'http://localhost:4000/meal';

            const method = editMode ? 'put' : 'post';
            
            await axios[method](url, formData, {
                headers: { 'Content-Type': 'multipart/form-data' }
            });

            resetForm();
            fetchMeals();
            alert(`Meal ${editMode ? 'updated' : 'created'} successfully!`);
        } catch (err) {
            console.error(err);
            alert(`Error ${editMode ? 'updating' : 'creating'} meal`);
        }
    };

    const handleEdit = (meal) => {
        setEditMode(true);
        setSelectedMeal(meal);
        setRecipe(meal.recipe);
        setAuthor(meal.author);
        setDate(new Date(meal.date).toISOString().split('T')[0]);
        setCookingTime(meal.cookingTime);
        setCalories(meal.calories);
        setCarbs(meal.carbs);
        setProtein(meal.protein);
        setFat(meal.fat);
        setNutInfo(meal.nutInfo);
        setIngredient(meal.ingredient);
        setProcess(meal.process);
        setDetails(meal.details);
        setCategory(meal.category);
        setIsVegan(meal.isVegan);
    };

    const handleDelete = async (id) => {
        if (window.confirm("Are you sure you want to delete this meal?")) {
            try {
                await axios.delete(`http://localhost:4000/meal/${id}`);
                fetchMeals();
                alert("Meal deleted successfully!");
            } catch (err) {
                console.error("Error deleting meal:", err);
                alert("Error deleting meal");
            }
        }
    };

    const resetForm = () => {
        setEditMode(false);
        setSelectedMeal(null);
        setRecipe('');
        setAuthor('');
        setDate('');
        setCookingTime('');
        setCalories('');
        setCarbs('');
        setProtein('');
        setFat('');
        setNutInfo('');
        setIngredient('');
        setProcess('');
        setImage(null);
        setDetails('');
        setCategory('Breakfast');
        setIsVegan(false);
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

    return(
        <div className='section'>
            <div className='sideNav'>
                <div className='features'>
                    <button className='btn dashboard' onClick={handleDashboard}>Dashboard</button>
                    <button className='btn exercise' onClick={handleExercise}>Exercise</button>
                    <button className='btn mealPlan' onClick={handleMeal}>Meal Plan</button>
                </div>
            </div>

            <div className='mealContent'>
                <form onSubmit={handleSubmit} encType="multipart/form-data">
                    <div className="Left">
                        <input type="text" value={recipe} placeholder="Recipe Name" 
                            onChange={(e) => setRecipe(e.target.value)} required /><br/>
                        <input type="text" value={author} placeholder="Author Name" 
                            onChange={(e) => setAuthor(e.target.value)} required /><br/>
                        <input type="date" value={date} 
                            onChange={(e) => setDate(e.target.value)} required /><br/>
                        <input type="text" value={cookingTime} placeholder="Cooking Time" 
                            onChange={(e) => setCookingTime(e.target.value)} required /><br/>
                        <input type="text" value={calories} placeholder="Calories" 
                            onChange={(e) => setCalories(e.target.value)} required /><br/>
                        <input type="text" value={carbs} placeholder="Carbohydrates" 
                            onChange={(e) => setCarbs(e.target.value)} required /><br/>
                        <input type="text" value={protein} placeholder="Protein" 
                            onChange={(e) => setProtein(e.target.value)} required /><br/>
                        <input type="text" value={fat} placeholder="Fat" 
                            onChange={(e) => setFat(e.target.value)} required /><br/>
                        <textarea value={nutInfo} placeholder="Nutritional Info" 
                            onChange={(e) => setNutInfo(e.target.value)} required /><br/>
                        <textarea value={process} placeholder="Cooking Process" 
                            onChange={(e) => setProcess(e.target.value)} required /><br/>
                    </div>

                    <div className="Right">
                        <input type="file" onChange={(e) => setImage(e.target.files[0])} 
                            accept="image/*" /><br/>
                        {image && <p>{image.name}</p>}

                        <select value={category} onChange={(e) => setCategory(e.target.value)} required>
                            <option value="Breakfast">Breakfast</option>
                            <option value="Meal">Meal</option>
                            <option value="Dinner">Dinner</option>
                        </select><br/>

                        <textarea value={details} placeholder="Recipe Details" 
                            onChange={(e) => setDetails(e.target.value)} required /><br/>
                        <textarea value={ingredient} placeholder="Ingredients" 
                            onChange={(e) => setIngredient(e.target.value)} required /><br/>
                        
                        <label>
                            <input type="checkbox" 
                                checked={isVegan} 
                                onChange={(e) => setIsVegan(e.target.checked)} />
                            Is Vegan
                        </label><br/>

                        <div className="form-buttons">
                            <button type="submit" className="submitbtn">
                                {editMode ? 'Update Meal' : 'Create Meal'}
                            </button>
                            {editMode && (
                                <button type="button" onClick={resetForm} className="cancelbtn">
                                    Cancel Edit
                                </button>
                            )}
                        </div>
                    </div>
                </form>
            </div>

            <div className='mealView'>
                <h2>Manage Meals</h2>
                <div className="mealGrid">
                    {meals.map(meal => (
                        <div key={meal._id} className="meal-card">
                            {meal.image && (
                                <img src={`http://localhost:4000/${meal.image}`} 
                                    alt={meal.recipe} 
                                    className="meal-image" />
                            )}
                            <div className="mealInfo">
                                <h3>{meal.recipe}</h3>
                                <p><strong>Category:</strong> {meal.category}</p>
                                <p><strong>Calories:</strong> {meal.calories}</p>
                                <p><strong>Vegan:</strong> {meal.isVegan ? 'Yes' : 'No'}</p>
                                <div className="meal-actions">
                                    <button className="edit-btn" onClick={() => handleEdit(meal)}>
                                        Edit
                                    </button>
                                    <button className="delete-btn" onClick={() => handleDelete(meal._id)}>
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

export default function Meal(){
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