import torch
from anyio.streams import file
from fastapi import APIRouter ,Depends ,File , UploadFile ,HTTPException , status
from typing import List
from app.dependencies.dependencies import get_model , get_device , get_class_names
from app.schemas.prediction import PredictionResponse , PredictionItem
from app.utils.image_utils import transform_image ,validate_and_prepare_image

router = APIRouter()

@router.post("/predict", response_model=PredictionResponse)
async def predict(
    file: UploadFile = File(..., description="The food image to classify."),
    model = Depends(get_model),
    device = Depends(get_device),
    class_names: List[str] = Depends(get_class_names)
):
    image_bytes,was_converted = await validate_and_prepare_image(file)
    # if not image_bytes:
    #     raise HTTPException(
    #         status_code=status.HTTP_400_BAD_REQUEST,
    #         detail="Could not read image"
    #     )
    try:
        img_tensor = transform_image(image_bytes)
        img_tensor = img_tensor.to(device)
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    with torch.no_grad():
        outputs = model(img_tensor)
        #Apply SoftMax to get probabilities
        probabilities = torch.nn.functional.softmax(outputs[0], dim=0)

    top5_prob , top5_idx = torch.topk(probabilities, 5)

    predictions = []

    for i in range(top5_prob.size(0)):
        confidence = top5_prob[i].item()
        class_name = class_names[top5_idx[i].item()]
        predictions.append(
            PredictionItem(class_name=class_name, confidence=confidence)
        )
    return PredictionResponse(
        top5_predictions=predictions,
        image_was_converted=was_converted
    )