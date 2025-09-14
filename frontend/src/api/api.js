import axios from "axios";

const API_BASE = "http://127.0.0.1:8000"; // backend URL

export const loginUser = async (credentials) => {
    const res = await axios.post(`${API_BASE}/auth/login`, credentials);
    return res.data;
};

export const fetchAthletes = async () => {
    const res = await axios.get(`${API_BASE}/results/athletes`);
    return res.data;
};

export const uploadVideo = async (file) => {
    const formData = new FormData();
    formData.append("file", file);
    const res = await axios.post(`${API_BASE}/upload_video/`, formData, {
        headers: { "Content-Type": "multipart/form-data" },
    });
    return res.data;
};
