import React, { useEffect, useState } from "react";
import { fetchAthletes } from "../api/api";
import AthleteProfile from "../components/AthleteProfile";

const Dashboard = () => {
    const [athletes, setAthletes] = useState([]);

    useEffect(() => {
        const getAthletes = async () => {
            const data = await fetchAthletes();
            setAthletes(data);
        };
        getAthletes();
    }, []);

    return (
        <div>
            <h2>Dashboard</h2>
            {athletes.map((a) => <AthleteProfile key={a.id} athlete={a} />)}
        </div>
    );
};

export default Dashboard;
