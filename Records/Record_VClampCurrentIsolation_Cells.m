%% Voltage Clamp experiments

reject_grid = {

'150727_F0_C0'  'Model cell'                    'Model cell, Change in resistance'
'150928_F0_C1'  'Model cell'                    'Model cell Rs'
'150715_F0_C1'  'Model cell'                    'Model cell'

'150617_F2_C1'  '20XUAS-mCD8:GFP;63A03-Gal4'         'Testing and analysis design'
'150704_F1_C1'  '10XUAS-mCD8:GFP;FruGal4'    'Testing drugs, 4AP->Cs->TTX->Cd'                 
'150706_F1_C1'  '10XUAS-mCD8:GFP;FruGal4'    'Testing drugs, TTX->4AP->Cs->Cd'                
'150709_F1_C2'  '10XUAS-mCD8:GFP;FruGal4'    'Testing drugs, TTX->4AP->TEA->CsCd'
   
'150723_F1_C1'  '10XUAS-mCD8:GFP;FruGal4'    'BPH. Used CsAsp internal without TEA'
'150730_F3_C1'  '10XUAS-mCD8:GFP;FruGal4'    'BPL. 0 Ca causes problems, lost it during TEA';
'150826_F2_C1'  '10XUAS-mCD8:GFP;FruGal4'    'BPL. Blew this one up, unfortunately';
'150827_F2_C1'  '10XUAS-mCD8:GFP;FruGal4'    'BPL. combined 4AP and TEA, blew it up, combined a lot of conditions, not a good protocol';
'150902_F1_C1'  '10XUAS-mCD8:GFP;FruGal4'    'TTX 4AP TEA cocktail all at once, compare MLA';

'150718_F1_C1'  '10XUAS-mCD8:GFP;FruGal4'    'High Access'
'150720_F1_C2'  '10XUAS-mCD8:GFP;FruGal4'    'High Access'
'150721_F2_C1'  '10XUAS-mCD8:GFP;FruGal4'    'High Access'

'150911_F1_C1'  'UAS-Dcr;10XUAS-mCD8:GFP/+;FruGal4/UAS-paraRNAi'    'BPL. What happens when blocking para with RNAi?'

'150913_F2_C1'  '10XUAS-mCD8:GFP;FruGal4'    'High Access'

'151002_F2_C1'  '10XUAS-mCD8:GFP;FruGal4'    'High Access'  
'151007_F4_C1'  '20XUAS-mCD8:GFP;VT27938-Gal4'  'High Access variance'  
'151021_F1_C1'  '10XUAS-mCD8:GFP;FruGal4'    'No effect of TEA or 4AP, not normal.'

'150826_F1_C1'  '10XUAS-mCD8:GFP;FruGal4'    'BPL. Fairly nice cell, not great access';
'151128_F2_C1'  '10XUAS-mCD8:GFP;FruGal4'    'BPH! Access drifts up.'

};

interesting_but_ancillary = {
'150903_F1_C1'  '10XUAS-mCD8:GFP;FruGal4'                        'BPL. MLA block. Starting to think about how to block this strange persistent K current.'
'150903_F2_C1'  '10XUAS-mCD8:GFP;FruGal4'                        'BPL. Charybdotoxin attempts.'
'150903_F3_C1'  '10XUAS-mCD8:GFP;FruGal4'                        'BPL. Charybdotoxin attempts.'
% '150912_F1_C1'  'UAS-Dcr;10XUAS-mCD8:GFP/+;FruGal4/UAS-paraRNAi'    'BPL. Older fly, clear Na currents, perhaps too old?'
'150912_F2_C1'  'UAS-Dcr;10XUAS-mCD8:GFP/+;FruGal4/UAS-paraRNAi'    'BPL. What happens when blocking para with RNAi? Younger fly, seems like there is not much left?'
'150926_F1_C1'  '10XUAS-mCD8:GFP;FruGal4'    'BPL. impact of series resistance compensation'
'151117_F1_C1'  '10XUAS-mCD8:GFP;FruGal4'    'BPH! ' 
% This cell, I did the NaV channel experiments. I think this really fucks
% the neuron up, compared to others. There is some severe hysteresis
% (TEA 4AP sensitive currents are not very big, probably because the
% neuron is hyperpolarized and K channels are severely deactivated)
};

analysis_grid = {...
%A2
'151030_F1_C1'      '20XUAS-mCD8:GFP;VT30609-Gal4'              'Beautiful cell, current isolation'
'151203_F3_C3'      '20XUAS-mCD8:GFP;VT30609-Gal4'        'Decent recording, saw spikes, but no current step injection before TTX'
'151203_F4_C1'      '20XUAS-mCD8:GFP;VT30609-Gal4'        'Decent recording, saw spikes, but no current step injection before TTX'
'151207_F1_C1'      '20XUAS-mCD8:GFP;VT30609-Gal4'        'Nice recording, cell in the nerve, quick dissection'
'151207_F2_C1'      '20XUAS-mCD8:GFP;VT30609-Gal4'        'Nice recording, cell in the nerve, quick dissection'

%Fru
%'150722_F1_C2'  '10XUAS-mCD8:GFP;FruGal4'    'BPH. ZD does take out Ih. Only 2.5V'
'150922_F2_C1'  '10XUAS-mCD8:GFP;FruGal4'    'BPH. Beautiful Cell in Fru Gal4, now need to switch the order of the drugs'
'151001_F1_C1'  '10XUAS-mCD8:GFP;FruGal4'    'BPL.'
'151001_F2_C1'  '10XUAS-mCD8:GFP;FruGal4'    'BPL.' % For this cell, the voltage changed during the curare, I've untagged the curare traces and excluded the cntrl trials
'151021_F3_C1'  '10XUAS-mCD8:GFP;FruGal4'    'BPH! Nice.'
'151022_F1_C1'  '10XUAS-mCD8:GFP;FruGal4'    'BPH! Access drifts up.'
'151210_F1_C1'  '10XUAS-mCD8:GFP;FruGal4'    'BPH! Access drifts up.' %
'151210_F2_C1'  '10XUAS-mCD8:GFP;FruGal4'    'BPH! Access drifts up.' 
'151210_F3_C1'  '10XUAS-mCD8:GFP;FruGal4'    'BPH! Access drifts up.' % ok

%VT
'151007_F1_C1'  '20XUAS-mCD8:GFP;VT27938-Gal4'  'LP. crapped out after TEA,NO TTX' % Should I throw this one out?
'151007_F3_C1'  '20XUAS-mCD8:GFP;VT27938-Gal4'  'LP. Should be good enough for gvt work'
'151009_F1_C1'  '20XUAS-mCD8:GFP;VT27938-Gal4'  'LP. '
'151022_F2_C1'  '20XUAS-mCD8:GFP;VT27938-Gal4'  'LP. '
'151029_F3_C1'  '20XUAS-mCD8:GFP;VT27938-Gal4'  'LP. '
'151118_F1_C1'  '20XUAS-mCD8:GFP;VT27938-Gal4'   'LP'
'151121_F3_C1'  '20XUAS-mCD8:GFP;VT27938-Gal4'   'Did the ramp at a different potential. What to do?' % For this cell, the voltage changed during the curare, I've untagged the curare traces and excluded the cntrl trials
}


cesiumPara_grid = {
%A2
%'151212_F1_C1'  'UAS-Dcr;20XUAS-mCD8:GFP/+;VT30609-Gal4/UAS-paraRNAi'   'A2, decent input currents, crapped out on the piezosines'                      %'VClamp, -5 pA' 
'151215_F3_C1'  'UAS-Dcr;20XUAS-mCD8:GFP/+;VT30609-Gal4/UAS-paraRNAi'   'A2, Gorgeous input currents for steps!'                                        %'VClamp, -5 pA' 
'151216_F2_C3'  'UAS-Dcr;20XUAS-mCD8:GFP/+;VT30609-Gal4/UAS-paraRNAi'   'A2, small input currents for steps, control cells for this fly'                %'VClamp, IClamp' 
'151216_F3_C2'  'UAS-Dcr;20XUAS-mCD8:GFP/+;VT30609-Gal4/UAS-paraRNAi'   'A2, small input currents for steps,control cells for this fly'       
'151217_F1_C3'  'UAS-Dcr;20XUAS-mCD8:GFP/+;VT30609-Gal4/UAS-paraRNAi'   'A2, really small input currents for steps, control antenna was free'           %'VClamp, whole cell on and off' 
'151217_F2_C1'  'UAS-Dcr;20XUAS-mCD8:GFP/+;VT30609-Gal4/UAS-paraRNAi'   'A2, assymetric step responses, sine responses oscillate'           %'VClamp, whole cell on and off' 
'151215_F2_C1'  'UAS-Dcr;20XUAS-mCD8:GFP/+;VT30609-Gal4/UAS-paraRNAi'   'Got an A2, but this one has spikes!'      % 'VClamp, IClamp' 

%Fru
'150912_F2_C1'  'UAS-Dcr;10XUAS-mCD8:GFP/+;FruGal4/UAS-paraRNAi'    'BPL. What happens when blocking para with RNAi? Younger fly, seems like there is not much left?'
'151015_F3_C1'  'UAS-Dcr;10XUAS-mCD8:GFP/+;FruGal4/UAS-paraRNAi'    'Antennal nerve cut, BPH (dim cell body), CsGluc internal'
'151016_F1_C1'  'UAS-Dcr;10XUAS-mCD8:GFP/+;FruGal4/UAS-paraRNAi'    'Antennal nerve intact, BPH (dim cell body), CsAsp TEA internal'
'151017_F1_C1'  'UAS-Dcr;10XUAS-mCD8:GFP/+;FruGal4/UAS-paraRNAi'    'still some Na currents remaining, band pass, identical to the others'
'151027_F2_C1'  'UAS-Dcr;10XUAS-mCD8:GFP/+;FruGal4/UAS-paraRNAi'    'Antennal nerve intact, BPH (dim cell body), CsAsp TEA internal'
'151027_F3_C1'  'UAS-Dcr;10XUAS-mCD8:GFP/+;FruGal4/UAS-paraRNAi'    'Antennal nerve intact, BPL (lower capacitance), CsAsp TEA internal'
'151028_F2_C1'  'UAS-Dcr;10XUAS-mCD8:GFP/+;FruGal4/UAS-paraRNAi'    'Antennal nerve intact, BPL (lower capacitance), CsAsp TEA internal'
'151110_F1_C1'  'UAS-Dcr;10XUAS-mCD8:GFP/+;FruGal4/UAS-paraRNAi'    'Antennal nerve intact, BPH (higher capacitance), CsAsp TEA internal'
'151110_F1_C2'  'UAS-Dcr;10XUAS-mCD8:GFP/+;FruGal4/UAS-paraRNAi'    'Antennal nerve intact, BPH (higher capacitance), CsAsp TEA internal'

%VT
'151017_F2_C1'  'UAS-Dcr;20XUAS-mCD8:GFP/+;VT27938-Gal4/UAS-paraRNAi'    'Antennal nerve intact, LP (lower capacitance), CsAsp TEA internal'
'151102_F1_C1'  'UAS-Dcr;20XUAS-mCD8:GFP/+;VT27938-Gal4/UAS-paraRNAi'    'Antennal nerve intact, LP (lower capacitance), CsAsp TEA internal'
'151102_F2_C1'  'UAS-Dcr;20XUAS-mCD8:GFP/+;VT27938-Gal4/UAS-paraRNAi'    'Antennal nerve intact, LP (lower capacitance), CsAsp TEA internal'
'151104_F1_C2'  'UAS-Dcr;20XUAS-mCD8:GFP/+;VT27938-Gal4/UAS-paraRNAi'    'Antennal nerve intact, LP (lower capacitance), CsAsp TEA internal'
'151108_F2_C1'  'UAS-Dcr;20XUAS-mCD8:GFP/+;VT27938-Gal4/UAS-paraRNAi'    'Antennal nerve intact, LP (lower capacitance), CsAsp TEA internal'
'151109_F1_C1'  'UAS-Dcr;20XUAS-mCD8:GFP/+;VT27938-Gal4/UAS-paraRNAi'    'Antennal nerve intact, LP (lower capacitance), CsAsp TEA internal' % access drifts up
'151109_F1_C2'  'UAS-Dcr;20XUAS-mCD8:GFP/+;VT27938-Gal4/UAS-paraRNAi'    'Antennal nerve intact, LP (lower capacitance), CsAsp TEA internal'
};

sham_grid = {
'150923_F1_C1'  '10XUAS-mCD8:GFP;FruGal4'    'BPL. control cell to check for drift'    
'151005_F1_C1'  '10XUAS-mCD8:GFP;FruGal4'                        'BPH. drift control, sham. Old KOH, bad internal'
'151005_F2_C1'  '10XUAS-mCD8:GFP;FruGal4'                        'BPL. drift control, sham. Old KOH, bad internal'
'151006_F3_C1'  '10XUAS-mCD8:GFP;FruGal4'                        'BPL. drift control, sham'
'151006_F3_C2'  '10XUAS-mCD8:GFP;FruGal4'                        'BPH. drift control, sham'    
};


%%
clear analysis_cell analysis_cells
% analysis_grid = cesiumPara_grid
for c = 1:size(analysis_grid,1)
    analysis_cell(c).name = analysis_grid{c,1}; 
    analysis_cell(c).genotype = analysis_grid{c,2}; %#ok<*SAGROW>
    analysis_cell(c).comment = analysis_grid{c,3};
    analysis_cells{c} = analysis_grid{c,1}; 
end
genotypes = analysis_grid(:,2);
[genotype_set,~,genotype_idx] = unique(genotypes);

Script_VClamp_Cells_A2
Script_VClamp_Cells_Fru
Script_VClamp_Cells_VT

Script_VClamp_Cells_Interesting
Script_VClamp_Cells_Reject

example_fru.name = '151210_F3_C1';
example_fru.VoltageSineTrial = ...
'C:\Users\tony\Raw_Data\151210\151210_F3_C1\VoltageSine_Raw_151210_F3_C1_98.mat';
example_fru.VoltageSineTrial_TTX = ...
'C:\Users\tony\Raw_Data\151210\151210_F3_C1\VoltageSine_Raw_151210_F3_C1_194.mat';
example_fru.VoltageSineTrial_4APTEA = ...
'C:\Users\tony\Raw_Data\151210\151210_F3_C1\VoltageSine_Raw_151210_F3_C1_482.mat';

example_vt.name = '151118_F1_C1';
example_vt.VoltageSineTrial = ...
'C:\Users\tony\Raw_Data\151118\151118_F1_C1\VoltageSine_Raw_151118_F1_C1_98.mat';
example_vt.VoltageSineTrial_TTX = ...
'C:\Users\tony\Raw_Data\151118\151118_F1_C1\VoltageSine_Raw_151118_F1_C1_189.mat';
example_vt.VoltageSineTrial_4APTEA = ...
'C:\Users\tony\Raw_Data\151118\151118_F1_C1\VoltageSine_Raw_151118_F1_C1_381.mat';

example_a2.name = '151207_F1_C1';
example_a2.VoltageSineTrial = ...
'C:\Users\tony\Raw_Data\151207\151207_F1_C1\VoltageSine_Raw_151207_F1_C1_98.mat';
example_a2.VoltageSineTrial_TTX = ...
'C:\Users\tony\Raw_Data\151207\151207_F1_C1\VoltageSine_Raw_151207_F1_C1_194.mat';
example_a2.VoltageSineTrial_4APTEA = ...
'C:\Users\tony\Raw_Data\151207\151207_F1_C1\VoltageSine_Raw_151207_F1_C1_290.mat';

example_fig8.VoltageStep = {
'C:\Users\tony\Raw_Data\151207\151207_F1_C1\VoltageStep_Raw_151207_F1_C1_1.mat';
'C:\Users\tony\Raw_Data\151022\151022_F1_C1\VoltageStep_Raw_151022_F1_C1_1.mat';
'C:\Users\tony\Raw_Data\151118\151118_F1_C1\VoltageStep_Raw_151118_F1_C1_1.mat';
};
example_fig8.example_cells = {
'151207_F1_C1';
'151022_F1_C1';
'151118_F1_C1';
};