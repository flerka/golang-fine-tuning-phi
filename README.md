# Go Code Collection & Preprocessing for Phi-3 Fine-Tuning

This repository contains scripts and tools to collect, preprocess, and prepare Go code/test file pairs for fine-tuning the Phi-3 language model for unit test generation. Phi-3 mini was selected due size and performance on tasks related to code-generation.

This project was imlemented from scratch using bash, GitHub API, and Unsloth library as a part of MSc project. Initial training was performed on Kaggle environment. The goal of the project was to evaluate the possibility of generating unit tests using a small fine-tuned model and compare results with state-of-the-art models.

---

## 📂 Repository Structure

| File | Description |
|------|-------------|
| `fetch-repositories-urls.py` | Python script to fetch repository URLs from GitHub API using batching. |
| `clone-repositories-optimised.sh` | Efficiently clones the repositories fetched earlier using shallow clones and other tricks. |
| `collect-files-in-folder.sh` | Filters and copies Go files into a single folder for further processing. |
| `preprocess-files.sh` | Cleans and filters the collected files to prepare them for dataset generation. |
| `generate-training-data.sh` | Converts preprocessed files into structured input/output pairs suitable for model fine-tuning. |
| `fine-tuning-and-inference-project-go-phi.ipynb` | A notebook to fine-tune the Phi-3 model on the generated dataset and perform inference on the trained model. |

---

## Features

- **Repository Fetching**: Automatically gather Go repository URLs according to specified criteria.
- **Preprocessing Pipeline**: Clean, filter, and normalize code and corresponding tests.
- **Training Dataset Generation**: Generate a dataset that contains Go code and test pairs.
- **Training pipeline using Unsloth library**: Jupyter notebook that contains the training and evaluation pipeline.

---

## Requirements
- Git installed  
- GitHub API key needs to be generated  
- Environment to run the notebook  
- Bash  

---

## License

This project is licensed under the MIT license.

---

## Todo

- Upload fine-tuned model to Hugging Face  
- Upload generated dataset to Hugging Face  
- Add instructions on how to run the code  
