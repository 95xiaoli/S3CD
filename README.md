# S3CD


The code is for paper "Unsupervised SAR Image Change Detection via Structure Feature-based Self-Representation Learning" by Weisong Li , Yinwei Li , Yiming Zhu , and Haipeng Wang.

To appear in IEEE TRANSACTIONS ON GEOSCIENCE AND REMOTE SENSING 2025 written by Weisong Li. Email: ws_li@usst.edu.cn; weisongli20@fudan.edu.cn

### Introduction

Unsupervised low-rank matrix decomposition (LRMD) theory, leveraging inherent structural features of images, has demonstrated significant potential for synthetic aperture radar (SAR) image change detection (CD) under label scarcity. However, conventional methods rely on static sparsity priors, which inadequately model the spatial diversity and dynamic complexity of changes, leading to great decomposition errors. To address this limitation, we redefine CD within a multiview framework and propose a structurally diversified self-representation learning model. By jointly enforcing low-rank and sparse constraints on the coefficient matrix, our approach enhances the global consistency and local continuity of change information, effectively rectifying representation errors in complex change patterns. Furthermore, a robust background suppression mechanism is integrated to mitigate speckle noise and pseudo-changes, improving the discriminability between changed and unchanged regions. To refine ambiguous
boundaries, an unsupervised classification refinement module is developed, calibrating transitional samples via nonlinear regression-based feature projection without labeled data. The entire framework operates without supervision, eliminating dependence on annotated samples. Extensive experiments on six bitemporal and three extended multitemporal datasets validate the effectiveness and superiority of the proposed method.

#### Requirements:
The code is tested on Windows 11 with MATLAB R2024a.

#### Usage:
- put pre-generated DI maps into the directory '\data'. It is recommended to us log-ratio operator to genrate intial DI maps.
- put their ground truth into the directory '\GT'.
- run 'main.m'



## <a name="Citation"></a>Citation
If you find our work helpful for your research, please consider citing the following BibTeX entry:
```text
@article{li2025unsupervised,
  title={Unsupervised SAR Image Change Detection via Structure Feature-based Self-Representation Learning},
  author={Li, Weisong and Li, Yinwei and Zhu, Yiming and Wang, Haipeng},
  journal={IEEE Transactions on Geoscience and Remote Sensing},
  year={2025},
  publisher={IEEE}
}
```

If you have any problem, please contact ws_li@usst.edu.cn.




#### Acknowledgments
Our algorithm is inspired by the work of *"Salient Object Detection via Structured Matrix Decomposition"* (IEEE TPAMI, 2016). 
- &zwnj;**Paper**&zwnj;: [Salient Object Detection via Structured Matrix Decomposition](https://ieeexplore.ieee.org/abstract/document/7464858)
- &zwnj;**DOI**&zwnj;: [10.1109/TPAMI.2016.2562626](http://dx.doi.org/10.1109/tpami.2016.2562626) 
- &zwnj;**Related Code**&zwnj;: [SMD](https://github.com/frankLeo123/Saliency_Matlab) 




