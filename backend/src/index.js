import express from "express";
import "dotenv/config";
import {clerkMiddleware}from "@clerk/express";
import User from "./models/User.model.js";
import {connectDB} from"./lib/db.js";

const app=express();
const PORT=process.env.PORT;

app.use(express.json())
app.use(cors({origin:FRONTEND_URL,credentials:true}));
app.use(clerkMiddleware());

app.get("/health",(req,res)=>{
    res.status(200).json({ok:true});
});

app.listen(PORT,()=>{
    connectDB();
    console.log("server is up and running on port:",PORT);
});