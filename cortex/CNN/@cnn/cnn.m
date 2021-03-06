%CNN convolutional neural network class 
%   Input (to constructor):
%    numHiddenLayer - total number of hidden layers
%    numFeature - feature maps per layer
%    filterSize - size of filter used by convn
%    numLabels - number of maps in output layer
%   OPTIONAL (pass either all or none):
%    fanIn - Boolean whether to use fan-in for weight initalization, LeCun et al. 1998 (fan-in)
%    fanOut - Boolean whether to use fan-out, see Glorot and Bengio, 2010
%    HeZhangRenSun - Boolean whether to use He, Zhang, Ren, Sun (2015)
%       initalization
%    normalizeLearningRates - Boolean whether to scale learning rates with
%       size of output patch
classdef cnn
    properties
        % Parameters
        numHiddenLayer
        numFeature
        filterSize
        run
        % Dependent parameters (calculated when calling initNet)
        randOfConvn
        numLayer
        layer
        % Parameter with default value
        normalize = true;
        % Anonymus functions and derivatives (loss func & nonlinearity)
        nonLinearity = @(x) 1.7159*tanh(0.66*x);
        nonLinearityD =@(x) 1.1325./(cosh(0.66*x).^2);
        lossFunction = @(x) 0.5*x.^2;
        lossFunctionD = @(x) x;
        % Added different initalization schemes 
        fanIn = false;
        fanOut = false;
        HeZhangRenSun = false;
        normalizeLearningRates = false;
    end
    methods
        function cnet = cnn(varargin)
            if nargin == 4 || nargin == 8
                cnet.numHiddenLayer =  varargin{1};
                cnet.numFeature = varargin{2};
                cnet.filterSize = varargin{3};
                cnet.run = varargin{4};
                if nargin == 8
                    if varargin{5} + varargin{6} + varargin{7} > 1
                        error('Can use only one of the initalization schemes');
                    end
                    cnet.fanIn = varargin{5};
                    cnet.fanOut = varargin{6};
                    cnet.HeZhangRenSun = varargin{7};
                    cnet.normalizeLearningRates = varargin{8};
                end
            else
                error('Pass either 4 or 8 input arguments');
            end
        end
        % After calling init changing parameters passed into constructor might become obsolete!
        function cnet = init(cnet)
            cnet.numLayer = cnet.numHiddenLayer + 2;
            cnet.randOfConvn = (cnet.numHiddenLayer + 1) * (cnet.filterSize - 1);
            % One map in input and three maps in output layer
            cnet.layer{1}.numFeature = 1;
            for l=1:cnet.numHiddenLayer
                cnet.layer{l+1}.numFeature = cnet.numFeature(l);
            end
            cnet.layer{cnet.numHiddenLayer+2}.numFeature = 1;
            % Initalize Weights and Biases randomly
            for l=2:length(cnet.layer)
                cnet.layer{l}.W = cell(cnet.layer{l}.numFeature, 1);
                for prevFm=1:cnet.layer{l-1}.numFeature
                    for fm=1:cnet.layer{l}.numFeature
                        if cnet.fanIn
                            % See LeCun et al. 1998 (fan-in)
                            limitsOfUniformDistribution = 2.4./(cnet.layer{l-1}.numFeature*prod(cnet.filterSize));
                            cnet.layer{l}.W{prevFm,fm} = limitsOfUniformDistribution*(2*(rand(cnet.filterSize)-0.5));
                            cnet.layer{l}.B = zeros(1,cnet.layer{l}.numFeature);
                        elseif cnet.fanOut
                            % See Glorot and Bengio, 2010 (proposed
                            % normalized initalization scheme)
                            limitsOfUniformDistribution = sqrt(6)./sqrt(cnet.layer{l-1}.numFeature*prod(cnet.filterSize)+...
                                cnet.layer{l}.numFeature*prod(cnet.filterSize));
                            cnet.layer{l}.W{prevFm,fm} = limitsOfUniformDistribution*(2*(rand(cnet.filterSize)-0.5));
                            cnet.layer{l}.B = zeros(1,cnet.layer{l}.numFeature);
                        elseif cnet.HeZhangRenSun
                            % See He, Zhang, Ren, Sun (2015)
                            stdF = sqrt(2./(cnet.layer{l-1}.numFeature*prod(cnet.filterSize)));
                            cnet.layer{l}.W{prevFm,fm} = stdF*randn(cnet.filterSize);
                            cnet.layer{l}.B = zeros(1,cnet.layer{l}.numFeature);
                        else
                            % Original initalization from SegEM paper
                            stdF = 1.3*3./prod(cnet.filterSize);
                            cnet.layer{l}.W{prevFm,fm} = stdF*randn(cnet.filterSize);
                            cnet.layer{l}.B = zeros(1,cnet.layer{l}.numFeature);
                        end
                    end
                end                
            end
        end
    end
end
