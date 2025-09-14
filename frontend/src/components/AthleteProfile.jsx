import React from "react";

const AthleteProfile = ({ athlete }) => {
    return (
        <div style={{ border: "1px solid #ccc", padding: "10px", margin: "10px" }}>
            <h3>{athlete.name}</h3>
            <p>Age: {athlete.age}</p>
            <p>Score: {athlete.latest_score}</p>
        </div>
    );
};

export default AthleteProfile;
