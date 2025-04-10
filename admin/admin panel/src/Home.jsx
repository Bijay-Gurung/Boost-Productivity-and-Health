import React, { useState, useEffect } from 'react';
import './home.css';
import { useNavigate, useLocation } from 'react-router-dom';
import axios from 'axios';

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
    const [users, setUsers] = useState([]);
    const [totalUsers, setTotalUsers] = useState(0);
    const [totalExercises, setTotalExercises] = useState(0);
    const [totalMeals, setTotalMeals] = useState(0);

    useEffect(() => {
        fetchUsers();
        fetchExercises();
        fetchMeals();
    }, []);
    
    const fetchUsers = () => {
        axios.get("http://localhost:4000/signup").then((res) => {
            setUsers(res.data);
            setTotalUsers(res.data.length);
        });
    };
    
    const fetchExercises = () => {
        axios.get("http://localhost:4000/exercise").then((res) => {
            setTotalExercises(res.data.length);
        });
    };
    
    const fetchMeals = () => {
        axios.get("http://localhost:4000/meal").then((res) => {
            setTotalMeals(res.data.length);
        });
    };
    

    const deleteUser = async (id) => {
        try {
            console.log("Deleting user with ID:", id);
            await axios.delete(`http://localhost:4000/signup/${id}`);
            alert("User deleted successfully");
            fetchUsers();
          } catch (err) {
            console.error("Error deleting user:", err);
            alert("Error deleting user");
          }
    };

    const editUser = (id) => {
        const newUserName = prompt("Enter new name:");
        const newEmail = prompt("Enter new email:");

        if (newUserName && newEmail) {
            axios.put(`http://localhost:4000/signup/${id}`, {
                userName: newUserName,
                email: newEmail
            }).then((res) => {
                const updated = users.map(user => user._id === id ? res.data : user);
                setUsers(updated);
            });
        }
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
                    <button className='btn dashboard' onClick={handleDashboard}>Dashboard</button><br/>
                    <button className='btn exercise' onClick={handleExercise}>Exercise</button><br/>
                    <button className='btn mealPlan' onClick={handleMeal}>Meal Plan</button><br/>
                </div>
            </div>

            <div className='content'>

            <div className="total">
                <div className="totalUser">
                    <h3>Total Users</h3>
                    <p>{totalUsers}</p>
                </div>

                <div className="totalExercise">
                    <h3>Total Exercises</h3>
                    <p>{totalExercises}</p>
                </div>

                <div className="totalMeal">
                    <h3>Total Meals</h3>
                    <p>{totalMeals}</p>
                </div>
            </div>

            <div className="userData">
            <h2>Manage Users</h2>
<table>
        <thead>
            <tr>
                <th>Name</th>
                <th>Email</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            {users.map((user) => (
                <tr key={user._id}>
                    <td>{user.userName}</td>
                    <td>{user.email}</td>
                    <td>
                        <button onClick={() => editUser(user._id)}>Edit</button>
                        <button onClick={() => deleteUser(user._id)}>Delete</button>
                    </td>
                </tr>
            ))}
        </tbody>
    </table>
            </div>
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