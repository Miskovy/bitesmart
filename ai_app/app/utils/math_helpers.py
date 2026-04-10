import numpy as np

def calculate_softmax(logits: np.ndarray) -> np.ndarray:
    """Computes softmax probabilities for numerical stability."""
    exp_logits = np.exp(logits - np.max(logits))
    return exp_logits / np.sum(exp_logits)


def get_top_k(probabilities: np.ndarray, k: int = 5):
    """Replicates torch.topk using pure NumPy."""
    top_indices = np.argsort(probabilities)[-k:][::-1]
    top_probs = probabilities[top_indices]
    return top_probs, top_indices