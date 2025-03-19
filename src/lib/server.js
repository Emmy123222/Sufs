import express from "express";
import Stripe from "stripe";
import cors from "cors";
import dotenv from "dotenv";
import path from "path";
import helmet from "helmet";

// Load environment variables from .env
dotenv.config({ path: path.resolve(process.cwd(), ".env") });

// Debug: Check if environment variables are loaded
console.log("🔹 Loaded ENV Variables:");
console.log({
  STRIPE_SECRET_KEY: process.env.STRIPE_SECRET_KEY
    ? "✅ Loaded"
    : "❌ Not Found",
  CLIENT_URL: process.env.CLIENT_URL || "https://r2a.netlify.app",
});

// Ensure essential environment variables exist
if (!process.env.STRIPE_SECRET_KEY) {
  throw new Error("❌ ERROR: Missing STRIPE_SECRET_KEY in .env file.");
}

// Initialize Express and Stripe
const app = express();
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY, {
  apiVersion: "2023-10-16",
});

// Middleware
app.use(express.json());
app.use(helmet());
app.use(
  cors({
    origin: [
      process.env.CLIENT_URL || "https://r2a.netlify.app",
      "http://localhost:3000",
    ],
    methods: ["POST"],
    allowedHeaders: ["Content-Type"],
  })
);

// 🟢 Debugging Endpoint - Check if Backend is Running
app.get("/", (req, res) => {
  res.send(" Stripe Backend is Running!");
});

// 🔹 Route to Create Stripe Checkout Session
app.post("/create-checkout-session", async (req, res) => {
  try {
    const { amount } = req.body;

    // Validate amount
    if (!amount || isNaN(amount) || amount <= 0) {
      console.error("❌ Invalid donation amount:", amount);
      return res.status(400).json({ error: "Invalid donation amount" });
    }

    console.log(`🔹 Received donation amount: NGN ${amount}`);

    // Ensure the amount is converted correctly to kobo
    const amountInKobo = Math.round(Number(amount) * 100);

    // Create Stripe checkout session
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ["card"],
      line_items: [
        {
          price_data: {
            currency: "ngn",
            product_data: {
              name: "Donation",
              description: "Support our mission",
            },
            unit_amount: amountInKobo,
          },
          quantity: 1,
        },
      ],
      mode: "payment",
      success_url: `${process.env.CLIENT_URL}/get-involved?payment=success`,
      cancel_url: `${process.env.CLIENT_URL}/get-involved?payment=cancelled`,
    });

    console.log("✅ Stripe Checkout Session Created:", session.id);
    res.json({ id: session.id });
  } catch (error) {
    console.error("❌ Stripe error:", error);
    res.status(500).json({
      error: "An error occurred while processing payment",
      details: error.message,
    });
  }
});

// Start the server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(` Server running on port ${PORT}`));
