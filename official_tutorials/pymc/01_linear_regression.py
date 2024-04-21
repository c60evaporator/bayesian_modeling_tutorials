"""
https://www.pymc.io/projects/docs/en/stable/learn/core_notebooks/pymc_overview.html
https://www.pymc.io/projects/docs/en/stable/learn/core_notebooks/GLM_linear.html
"""
#%% Generate data
import arviz as az
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
from scipy import stats
import xarray as xr
import sys

RANDOM_SEED = 8927
rng = np.random.default_rng(RANDOM_SEED)
az.style.use("arviz-darkgrid")

# True parameter values
alpha, sigma = 1, 1
beta = [1, 2.5]

# Size of dataset
size = 100

# Predictor variable
X1 = np.random.randn(size)
X2 = np.random.randn(size) * 0.2

# Simulate outcome variable
Y = alpha + beta[0] * X1 + beta[1] * X2 + rng.normal(size=size) * sigma

fig, axes = plt.subplots(1, 2, sharex=True, figsize=(10, 4))
axes[0].scatter(X1, Y, alpha=0.6)
axes[1].scatter(X2, Y, alpha=0.6)
axes[0].set_ylabel("Y")
axes[0].set_xlabel("X1")
axes[1].set_xlabel("X2")

# %% Model specification
import pymc as pm

print(f"Running on PyMC v{pm.__version__}")

basic_model = pm.Model()

with basic_model:
    # Priors for unknown model parameters
    alpha = pm.Normal("alpha", mu=0, sigma=10)
    beta = pm.Normal("beta", mu=0, sigma=10, shape=2)
    sigma = pm.HalfNormal("sigma", sigma=1)

    # Expected value of outcome
    mu = alpha + beta[0] * X1 + beta[1] * X2

    # Likelihood (sampling distribution) of observations
    Y_obs = pm.Normal("Y_obs", mu=mu, sigma=sigma, observed=Y)

# %% Visualize the model
pm.model_to_graphviz(basic_model)

# %% Execute MCMC
with basic_model:
    # draw 1000 posterior samples
    idata = pm.sample()

# %% Summary of the generated samples
idata

# %% Extract part of the MCMC sample
idata.posterior["alpha"].sel(draw=slice(0, 4))

# %% Trace plot
az.plot_trace(idata, combined=True)

# %% Summary of the result
az.summary(idata, round_to=2)

# %% Plot the credible and predition interval
X2_BY = 0.2
X2_CENTER = 0
N_IMAGES = 4
x2_borders = [X2_CENTER - X2_BY * (N_IMAGES/2 - 1) + X2_BY * i for i in range(N_IMAGES - 1)]

fig_cred, axes_cred = plt.subplots(nrows=1, ncols=N_IMAGES, figsize=(N_IMAGES * 4, 4))
fig_pred, axes_pred = plt.subplots(nrows=1, ncols=N_IMAGES, figsize=(N_IMAGES * 4, 4))

for img_idx in range(N_IMAGES):
    # Minimum, Maximum, Representative value of x2 in the image
    x2_min = -sys.float_info.max if img_idx == 0 else x2_borders[img_idx - 1]
    x2_max = sys.float_info.max if img_idx == len(x2_borders) else x2_borders[img_idx]
    x2_rep = x2_borders[0] - X2_BY / 2 if img_idx == 0 else x2_borders[img_idx - 1] + X2_BY / 2
    # Extract the obserbed data whose x2 value is in the range of the image
    x2_mask = np.where((x2_min <= X2) & (X2 < x2_max))
    X1_filtered = X1[x2_mask]
    Y_filtered = Y[x2_mask]
    # Create x1 list for plotting image
    x1_min, x1_max = np.min(X1), np.max(X1)
    x1_grid = np.linspace(x1_min, x1_max, num=100)
    # Add intercept and x2 on x1 grid
    X_grid = np.insert(x1_grid.reshape(-1, 1), 0, 1, axis=1)
    X_grid = np.insert(X_grid, 2, x2_rep, axis=1)
    # Calculate posterior mu on the grid data (shape=(chain, n_samples, n_x1))
    mu_posterior = idata.posterior["alpha"] * xr.DataArray(X_grid[:, 0], dims=["x1"]) \
        + idata.posterior["beta"][:, :, 0] * xr.DataArray(X_grid[:, 1], dims=["x1"]) \
        + idata.posterior["beta"][:, :, 1] * xr.DataArray(X_grid[:, 2], dims=["x1"])
    # Plot the credible interval of mu
    x2_min_label = '' if img_idx == 0 else str(round(x2_min, 4))
    x2_max_label = '' if img_idx == len(x2_borders) else str(round(x2_max, 4))
    az.plot_hdi(x1_grid, mu_posterior, hdi_prob=0.95, ax=axes_cred[img_idx])
    axes_cred[img_idx].plot(x1_grid, np.mean(mu_posterior.to_numpy(), axis=(0, 1)), color='red')
    sns.scatterplot(x=X1_filtered, y=Y_filtered, ax=axes_cred[img_idx])
    axes_cred[img_idx].set_xlabel('x1')
    axes_cred[img_idx].set_xlabel('y')
    axes_cred[img_idx].set_title(f'x2={x2_min_label}-{x2_max_label}')
    # Calculate posterior predictive distribution (shape=(chain, n_samples, n_x1))
    sigma_posterior = idata.posterior["sigma"].to_numpy()
    posterior_predictive = []
    for i_x1 in range(len(x1_grid)):  # calculate for every x1 value
        mu_posterior_i = mu_posterior[:, :, i_x1].to_numpy()
        posterior_predictive.append(stats.norm.rvs(
            loc=mu_posterior_i,
            scale=sigma_posterior,
            size=mu_posterior_i.shape
        ))
    posterior_predictive = np.array(posterior_predictive).transpose(1, 2, 0)
    # Plot the prediction interval
    az.plot_hdi(x1_grid, posterior_predictive, hdi_prob=0.95, ax=axes_pred[img_idx])
    axes_pred[img_idx].plot(x1_grid, np.mean(posterior_predictive, axis=(0, 1)), color='red')
    sns.scatterplot(x=X1_filtered, y=Y_filtered, ax=axes_pred[img_idx])
    axes_pred[img_idx].set_xlabel('x1')
    axes_pred[img_idx].set_xlabel('y')
    axes_pred[img_idx].set_title(f'x2={x2_min_label}-{x2_max_label}')
    # Create (x1,y) grid for plotting image
    # y_min, y_max = np.min(Y), np.max(Y)
    # y_grid = np.linspace(y_min, y_max, num=100)
    # _X1, _Y = np.meshgrid(x1_grid, y_grid)
    # XY_grid = np.c_[_X1.ravel(), _Y.ravel()]

fig_cred.suptitle('Credible interval of mu', fontsize=20)
fig_pred.suptitle('Prediction interval', fontsize=20)

# %%
