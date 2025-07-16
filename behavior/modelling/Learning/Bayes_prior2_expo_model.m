function LL = Bayes_prior2_expo_model(theta, nBlue_mat, N_mat, p_responses)
%Bayesian model with exponential evidence weight and noisy choice

prior = theta(1);
expo = theta(2);
sigma = theta(3);

    for tr = 1:length(p_responses)
        
        % get trial N blue and sample sizes
        nBlue=nBlue_mat(tr,:);
        N=N_mat(tr,:);
        
        % initial values of the beta distribution
        alpha = prior;
        beta = prior;

        for b = 1:length(nBlue)

            %update beta parameters
            alpha = alpha + nBlue(b).^expo;
            beta = beta + (N(b)-nBlue(b)).^expo;


        end
        
        %catch infinites
        if isinf(alpha)
            alpha = 10^10;
        elseif isinf(beta)
            beta = 10^10;
        end
        
        % get trial log likelihood
        trunc_norm = makedist('Normal', alpha/(alpha+beta), sigma);
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