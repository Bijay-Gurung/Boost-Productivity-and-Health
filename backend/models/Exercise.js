const ExerciseSchema = new mongoose.Schema({
    name: { type: String, required: true },
    category: { type: mongoose.Schema.Types.ObjectId, ref: 'ExerciseCategory', required: true },
    caloriesPerSet: { type: Number, required: true },
    steps: [{ type: String }],
    media: { type: String },
    defaultSets: { type: Number, default: 3 },
    defaultReps: { type: Number, default: 12 }
  });
  
  module.exports = mongoose.model('Exercise', ExerciseSchema);