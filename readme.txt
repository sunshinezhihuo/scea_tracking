SCEA ver1 (last updated 20160620)

IMPORTANT:

1. If you use this code, please cite the following publication.

[1] Online Multi-Object Tracking via Structural Constraint Event Aggregation,
Ju Hong Yoon, Chang-Ryeol Lee, Ming-Hsuan Yang, and Kuk-Jin Yoon, 
IEEE Conference on Computer Vision and Pattern Recognition (CVPR), 2016.

project page: https://cvl.gist.ac.kr/project/scea.html 

2. The code was tested on MATLAB 2014a (Windows 7).

3. The ZIP file contains our results on MOTChallange dataset and KITTI dataset.


INSTALLING & RUNNING (MATLAB 32/64bit)

1. Unpack scea_v1.0.zip

2. Carefully check the detection format
   
    - observation{f}.bbox: 'f' is frame index 
    - a set of detections are represented by N by M matrix where N is # of detections and M is the detection dimension (It is 4).

3. Run demo_scea_ver1.m

4. The tracking results will be given in the folder: ./result/

5. Result format

* mat file
       
        stateInfo.tiToInd(frame,i) =  idx; % frame: frame index, i: track index
        stateInfo.stateVec = [stateInfo.stateVec;State(1)];
        stateInfo.X(frame,i) = State(1);   
        stateInfo.Y(frame,i) = State(2);
        stateInfo.Xgp(frame,i) =  State(1); % X position
        stateInfo.Ygp(frame,i) =  State(2); % Y position
        stateInfo.Xi(frame,i) =  State(1);
        stateInfo.Yi(frame,i) =  State(2);
        stateInfo.H(frame,i) =  State(4); % Width
        stateInfo.W(frame,i) =  State(3); % Height
 
* txt file format

 - Please see the groundthruth format in 'motchallenge.net'
 







