import React from "react";
import { Link } from "react-router-dom";

const Navbar = () => {
    return (
        <nav style={{ padding: "10px", background: "#2c3e50", color: "white" }}>
            <h2>Sports Talent App</h2>
            <Link to="/dashboard" style={{ margin: "0 10px", color: "white" }}>Dashboard</Link>
            <Link to="/reports" style={{ margin: "0 10px", color: "white" }}>Reports</Link>
        </nav>
    );
};

export default Navbar;
