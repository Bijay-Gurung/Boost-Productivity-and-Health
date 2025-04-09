import React, { useState } from 'react';
import "./meal.css";
import "./Home";
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
    const [image, setImage] = useState('');
    const [details, setDetails] = useState('');
    const [category, setCategory] = useState('Breakfast');
    const [isVegan, setIsVegan] = useState('false');

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
        formData.append('image', image);
        formData.append('details', details);
        formData.append('category', category);
        formData.append('isVegan', isVegan);
    
        axios.post("http://localhost:4000/meal", formData, {
            headers: {
                'Content-Type': 'multipart/form-data'
            }
        })
        .then(result => {
            console.log(result);
            alert("New Recipe has been created");
        })
        .catch(err => console.log(err));
    }

    return(
        <div className='section'>
            <div className='sideNav'>
                <div className='features'>
                    <button className='btn dashboard' onClick={handleDashboard}>Dashboard</button><br/>
                    <button className='btn exercise' onClick={handleDashboard}>Exercise</button><br/>
                    <button className='btn mealPlan' onClick={handleMeal}>Meal Plan</button><br/>
                    <button className='btn settings' onClick={handleDashboard}>Settings</button>
                </div>
            </div>

            <div className='content'>
                <h1>Meal Plan</h1>
                <form onSubmit={handleSubmit} encType="multipart/form-data">
                <div className="left">
                    <input type="text" id="recipe" name="recipe" placeholder="Recipe Name" onChange={(e) => setRecipe(e.target.value)} required /><br/>
                    <input type="text" id="author" name="author" placeholder="Author Name" onChange={(e) => setAuthor(e.target.value)} required /><br/>
                    <input type="date" id="date" name="date" placeholder="Date" onChange={(e) => setDate(e.target.value)} required /><br/>
                    <input type="text" id="cookingTime" name="cookingTime" placeholder="Cooking Time" onChange={(e) => setCookingTime(e.target.value)} required /><br/>
                    <input type="text" id="calories" name="calories" placeholder="Calories" onChange={(e) => setCalories(e.target.value)} required /><br/>
                    <input type="text" id="carbs" name="carbs" placeholder="Carbohydrates" onChange={(e) => setCarbs(e.target.value)} required /><br/>
                    <input type="text" id="protein" name="protein" placeholder="Protein" onChange={(e) => setProtein(e.target.value)} required /><br/>
                    <input type="text" id="fat" name="fat" placeholder="Fat" onChange={(e) => setFat(e.target.value)} required /><br/>
                    <textarea rows='5' cols='29' id="nutInfo" name="nutInfo" placeholder="Add Nutritional Info" onChange={(e) => setNutInfo(e.target.value)} required></textarea><br/>
                    <textarea rows='5' cols='29' id="process" name="process" placeholder="Add the process of recipe" onChange={(e) => setProcess(e.target.value)} required></textarea><br/>
                </div>

                <div className="right">
                    <input type="file" id="recipeImage" name="recipeImage" placeholder="Upload Recipe Image" onChange={(e) => setImage(e.target.files[0])} required /><br/>
                    <select name="category" id="category" onChange={(e) => setCategory(e.target.value)} required>
                        <option value="Breakfast">Breakfast</option>
                        <option value="Meal">Meal</option>
                        <option value="Dessert">Dessert</option>
                    </select><br/>
                    <textarea rows='5' cols='29' id="details" name="details" placeholder="Write your recipe details here" onChange={(e) => setDetails(e.target.value)} required></textarea><br/>
                    <textarea rows='5' cols='29' id="ingredient" name="ingredient" placeholder="Add Ingredient" onChange={(e) => setIngredient(e.target.value)} required></textarea><br/>
                    <label><input type="checkbox" name="isVegan" checked={isVegan === 'true'} onChange={(e) => setIsVegan(e.target.checked ? 'true' : 'false')}/>Is Vegan</label>
                    <button type="submit">Create</button>
                </div>
            </form>
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