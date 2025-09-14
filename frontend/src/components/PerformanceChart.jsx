import React from "react";
import { LineChart, Line, XAxis, YAxis, Tooltip, CartesianGrid } from "recharts";

const PerformanceChart = ({ data }) => {
    return (
        <LineChart width={600} height={300} data={data}>
            <XAxis dataKey="date" />
            <YAxis />
            <Tooltip />
            <CartesianGrid stroke="#eee" strokeDasharray="5 5" />
            <Line type="monotone" dataKey="score" stroke="#8884d8" />
        </LineChart>
    );
};

export default PerformanceChart;
