import React from "react";
import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import Navbar from "./components/Navbar";
import Login from "./pages/Login";
import Dashboard from "./pages/Dashboard";
import Reports from "./pages/Reports";

const App = () => {
    return (
        <Router>
            <Navbar />
            <Routes>
                <Route path="/" element={<Login />} />
                <Route path="/dashboard" element={<Dashboard />} />
                <Route path="/reports" element={<Reports />} />
            </Routes>
        </Router>
    );
};

export default App;
