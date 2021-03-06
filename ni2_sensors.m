function sens = ni2_sensors(varargin)

% NI2_SENSORS create a fictive sensor-array. 
%
% Use as
%  sens = ni2_sensors('type', senstype);
%
% Where senstype can be any of the following:
%  'eeg' generates a 91-channel eeg sensor array
%  'meg' generates a 301-channel meg magnetometer sensor array
%  'meg_grad_axial' generates a 301-channel meg axial gradiometer sensor
%  array.


type   = ft_getopt(varargin, 'type', 'eeg');
jitter = ft_getopt(varargin, 'jitter', 0);
n      = ft_getopt(varargin, 'n', 162); % number of vertices for the sphere, determines the number of electrodes, this is the old default

switch type
  case 'eeg'
    % create an eeg electrode array
    [chanpos, tri] = mesh_sphere(n);
    chanpos        = chanpos*10;
    chanpos(chanpos(:,3)<0,:) = [];
    
    if jitter
      [th,phi,r] = cart2sph(chanpos(:,1), chanpos(:,2), chanpos(:,3));
      shift1 = 2*jitter*(rand(numel(th),1)  - 1);
      shift2 = 2*jitter*(rand(numel(phi),1) - 1);
      [chanpos(:,1),chanpos(:,2),chanpos(:,3)] = sph2cart(th+shift1(:),phi+shift2(:),r);
    end
      
    sens.chanpos = chanpos;
    sens.elecpos = chanpos;
    for k = 1:size(chanpos,1)
      sens.label{k,1}    = sprintf('eeg% 02d', k);
      sens.chantype{k,1} = 'eeg';
    end
    sens = ft_datatype_sens(sens);
    
    
  case {'meg_mag' 'meg'}
    % create an meg magnetometer array
    [chanpos, tri] = icosahedron642;
    chanpos        = chanpos*12.5;
    chanpos(:,3)   = chanpos(:,3) - 1.5;
    
    [x, y, z, chanpos, tri] = intersect_plane(chanpos, tri, [0 0 0], [1 0 0], [0 1 0]);
    coilori                 = normals(chanpos, tri, 'vertex');
  
    nchan        = size(chanpos,1);
    sens.chanpos = chanpos;
    sens.chanori = coilori;
    sens.coilpos = chanpos;
    sens.coilori = coilori;
    sens.tra     = eye(nchan);
    for k = 1:nchan
      sens.label{k,1}    = sprintf('meg% 03d', k);
      sens.chantype{k,1} = 'megmag';
    end
    sens = ft_datatype_sens(sens);
    sens.tri = tri;
    
  case 'meg_grad_axial'
    % create an meg axial gradiometer array
    [chanpos, tri] = icosahedron642;
    chanpos        = chanpos*12.5;
    chanpos(:,3)   = chanpos(:,3) - 1.5;
    
    [x, y, z, chanpos, tri] = intersect_plane(chanpos, tri, [0 0 0], [1 0 0], [0 1 0]);
    coilori                 = normals(chanpos, tri, 'vertex');
  
    nchan        = size(chanpos,1);
    sens.chanpos = chanpos;
    sens.chanori = coilori;
    sens.coilpos = [chanpos; chanpos+5*coilori];
    sens.coilori = [coilori; -coilori];
    sens.tra     = [eye(nchan) eye(nchan)];
    for k = 1:nchan
      sens.label{k,1}    = sprintf('meg% 03d', k);
      sens.chantype{k,1} = 'meggrad';
    end
    sens = ft_datatype_sens(sens);
    sens.tri = tri;
    
    
  case 'meg_grad_planar'
    % not implemented yet
  case 'meg_ctf275'
    load('ctf275');
  case 'meg_ctf151'
    load('ctf151');
  case 'meg_bti248'
    load('bti248');
  case 'meg_neuromag306'
    load('neuromag306');
  otherwise
    error('unsupported type % s', type);
end
 