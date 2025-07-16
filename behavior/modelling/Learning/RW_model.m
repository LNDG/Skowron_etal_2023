function LL = RW_model(theta, nBlue_mat, N_mat, p_responses)
%Bayesian model with exponential evidence weight and linear learing rate

alpha = theta(1);
sigma = theta(2);

    for tr = 1:length(p_responses)
        
        % get trial N blue and sample sizes
        nBlue=nBlue_mat(tr,:);
        N=N_mat(tr,:);
        
        pBlue = 0.5; % intialise estimate

        for b = 1:length(nBlue)

            %update marble ratio estimate
            er = pBlue - (nBlue(b)/N(b));
            
            pBlue = pBlue - alpha * er;


        end
        
        % get trial log likelihood
        trunc_norm = makedist('Normal', pBlue, sigma);
        trunc_norm = truncate(trunc_norm,0,1); % truncated normal distribution
        like=pdf(trunc_norm,p_responses(tr));
        
        if like == 0
           like = 10^-5;
        end
        
        LL_mat(tr) = log(like);
    
    end
    
    % get joint negative log likelihood
    LL = -sum(LL_mat);

end