/**
 * @file
 * @brief Header file that includes the version number of libopenshot
 * @author Jonathan Thomas <jonathan@openshot.org>
 *
 * @ref License
 */

/* LICENSE
 *
 * Copyright (c) 2008-2019 OpenShot Studios, LLC
 * <http://www.openshotstudios.com/>. This file is part of
 * OpenShot Library (libopenshot), an open-source project dedicated to
 * delivering high quality video editing and animation solutions to the
 * world. For more information visit <http://www.openshot.org/>.
 *
 * OpenShot Library (libopenshot) is free software: you can redistribute it
 * and/or modify it under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * OpenShot Library (libopenshot) is distributed in the hope that it will be
 * useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with OpenShot Library. If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef OPENSHOT_VERSION_H
#define OPENSHOT_VERSION_H

#define OPENSHOT_VERSION_ALL "0.2.5"        /// A string of the entire version "Major.Minor.Build"
#define OPENSHOT_VERSION_FULL "0.2.5-dev3"   /// A string of the full version identifier, including suffixes (e.g. "0.0.0-dev0")

#define OPENSHOT_VERSION_MAJOR_MINOR "0.2" /// A string of the "Major.Minor" version

#define OPENSHOT_VERSION_MAJOR 0   /// Major version number is incremented when huge features are added or improved.
#define OPENSHOT_VERSION_MINOR 2   /// Minor version is incremented when smaller (but still very important) improvements are added.
#define OPENSHOT_VERSION_BUILD 5   /// Build number is incremented when minor bug fixes and less important improvements are added.

#define OPENSHOT_VERSION_SO 19         /// Shared object version number. This increments any time the API and ABI changes (so old apps will no longer link)

// Useful dependency versioning / feature availability
#define QT_VERSION_STR "5.15.2"
#define AVCODEC_VERSION_STR "58.134.100"
#define AVFORMAT_VERSION_STR "58.76.100"
#define AVUTIL_VERSION_STR "56.70.100"
#define OPENCV_VERSION_STR "4.5.2"
#define HAVE_IMAGEMAGICK 1
#define HAVE_RESVG 0
#define HAVE_OPENCV 1
#define FFMPEG_USE_SWRESAMPLE 1
#define APPIMAGE_BUILD 0

#include <sstream>

namespace openshot
{
	/// This struct holds version number information. Use the GetVersion() method to access the current version of libopenshot.
	struct OpenShotVersion {
		static const int Major = OPENSHOT_VERSION_MAJOR; /// Major version number
		static const int Minor = OPENSHOT_VERSION_MINOR; /// Minor version number
		static const int Build = OPENSHOT_VERSION_BUILD; /// Build number
		static const int So = OPENSHOT_VERSION_SO; /// Shared Object Number (incremented when API or ABI changes)

		/// Get a string version of the version (i.e. "Major.Minor.Build")
		inline static const std::string ToString() {
			std::stringstream version_string;
			version_string << Major << "." << Minor << "." << Build;
			return version_string.str();
		}
	};

	static const openshot::OpenShotVersion Version;

	/// Get the current version number of libopenshot (major, minor, and build number)
	openshot::OpenShotVersion GetVersion();
}

#endif // OPENSHOT_VERSION_H
