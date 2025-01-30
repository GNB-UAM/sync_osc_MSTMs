%% Profile v 1.0 29.9.2016: Eero Satuvuori
% Object for storing the data and plotting ISI-profile and SPIKE-profile
%
%   The Profile object is created by the object SpikeTrainSet upon calling
%   for the ISI- and the SPIKE-distance based profiles.
%
%   Xvalues = PlotProfileX()
%       Returns the X-ticks of the profile as a vector
%   Yvalues = PlotProfileY()
%       Returns the Y-values of the profile that are matched to their
%       corresponding index values in the Xvalues. 
%   Plot(obj,colour,alpha)
%       Plots the profile to the current axis with colour defined. Alpha is
%       the opacity of the profile. For 1 the profile is solid and for 0.1
%       almost transparent.


classdef Profile < handle
    
    properties (Access = private)
        ProfileArray;
    end
    methods (Access = private)
        function CheckData(obj,Data)


                if ndims(Data)~=2 || size(Data,1) ~= 2;
                     error('Data is incorrectly aligned');
                end                


                 if ~isnumeric(Data)
                     error('Data is not all numeric');
                 end

        end
    end
    methods (Access = public)
        %%
        function obj = Profile(ProfileData)
            obj.CheckData(ProfileData);
            obj.ProfileArray = ProfileData;
            
        end
        
        %%
        function Xvalues = PlotProfileX(obj)
            Xvalues = obj.ProfileArray(2,:);
        end
        %%
        
        function Yvalues = PlotProfileY(obj)
            Yvalues = obj.ProfileArray(1,:);
        end
        %%
        
        function Plot(obj,colour,alpha)
            if nargin < 2
                colour = 'blue';
            end
            if nargin < 3
                alpha = 0.4;
            end
            plotVector1 = [obj.ProfileArray(2,:),fliplr(obj.ProfileArray(2,:))];
            plotVector2 = [obj.ProfileArray(1,:),zeros(1,length(obj.ProfileArray(1,:)))];
            
            
            plot(obj.ProfileArray(2,:),obj.ProfileArray(1,:),colour)
            filling = fill(plotVector1,plotVector2,colour);
            set(filling,'FaceAlpha',alpha);
            ylim([0,1]);
          
        end
    end
    
end

