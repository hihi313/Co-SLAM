import pkg_resources

def find_package_directory(package_name):
    try:
        distribution = pkg_resources.get_distribution(package_name)
        return distribution.location
    except pkg_resources.DistributionNotFound:
        return None

package_name = "marching_cubes"  # Replace with the desired package name
package_directory = find_package_directory(package_name)

if package_directory:
    print(f"The directory of package '{package_name}' is: {package_directory}")
else:
    print(f"Package '{package_name}' is not installed.")
