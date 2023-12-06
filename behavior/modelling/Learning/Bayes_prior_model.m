function LL = Bayes_prior_model(prior, nBlue_mat, N_mat, p_responses)
%Bayesian model with exponential evidence weight

    for tr = 1:length(p_responses)
        
        % get trial N blue and sample sizes
        nBlue=nBlue_mat(tr,:);
        N=N_mat(tr,:);
        
        % initial values of the beta distribution
        alpha = prior;
        beta = prior;

        for b = 1:length(nBlue)

            %update beta parameters
            alpha = alpha + nBlue(b);
            beta = beta + (N(b)-nBlue(b));


        end
        
        % get trial log likelihood
        like=betapdf(p_responses(tr),alpha,beta);
        
        if like == 0
           like = 10^-5;
        end
        
        LL_mat(tr) = log(like);
    
    end
    
    % get joint negative log likelihood
    LL = -sum(LL_mat);

end