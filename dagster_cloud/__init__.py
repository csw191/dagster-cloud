from dagster import Definitions, asset
 
@asset
def sample_asset():
    """A simple sample asset for testing deployment."""
    return "Hello from Dagster Cloud!"
 
# Export definitions so Dagster can find them
defs = Definitions(
    assets=[sample_asset]
)
