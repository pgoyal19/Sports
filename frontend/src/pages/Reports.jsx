import React from "react";
import PerformanceChart from "../components/PerformanceChart";

const Reports = () => {
    // Dummy Data (replace with API call)
    const data = [
        { date: "2025-09-01", score: 80 },
        { date: "2025-09-02", score: 85 },
        { date: "2025-09-03", score: 90 },
    ];

    return (
        <div>
            <h2>Performance Reports</h2>
            <PerformanceChart data={data} />
        </div>
    );
};

export default Reports;
