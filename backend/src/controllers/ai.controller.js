// const aiService =require("../services/ai.service")


// module.exports.getResponse=async (req,res)=>{
//     const prompt =req.query.prompt;
//     if(!prompt){
//         return res.status(400).send("Prompt is required");
//     }
//     const response =await aiService(prompt);
//     res.send(response);
// }

import generateContent from "../services/ai.service.js";

export const getReview = async (req, res) => {
  try {
    const code = req.body.code;
    const response = await generateContent(code);
    res.json({ reply: response });
  } catch (err) {
    console.error(err);
    res.status(500).send("Error generating content");
  }
};
