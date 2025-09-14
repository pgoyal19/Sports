import React, { useState } from "react";
import { loginUser } from "../api/api";
import { useNavigate } from "react-router-dom";

const Login = () => {
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const navigate = useNavigate();

    const handleLogin = async () => {
        try {
            await loginUser({ email, password });
            navigate("/dashboard");
        } catch (err) {
            alert("Login failed");
        }
    };

    return (
        <div style={{ padding: "50px" }}>
            <h2>Login</h2>
            <input type="email" placeholder="Email" onChange={(e) => setEmail(e.target.value)} />
            <br /><br />
            <input type="password" placeholder="Password" onChange={(e) => setPassword(e.target.value)} />
            <br /><br />
            <button onClick={handleLogin}>Login</button>
        </div>
    );
};

export default Login;
