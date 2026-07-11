class QualityItemConfig {
	final String id;
	final String label;
	final String dataSource;
	final String? unit;
	final List<QualityItemConfig>? structure;

	const QualityItemConfig({
		required this.id,
		required this.label,
		required this.dataSource,
		this.unit,
		this.structure,
	});

	factory QualityItemConfig.fromJson(Map<String, dynamic> json) {
		return QualityItemConfig(
			id: json['id'] as String,
			label: json['label'] as String,
			dataSource: json['dataSource'] as String,
			unit: json['unit'] as String?,
			structure: json['structure'] != null
					? (json['structure'] as List)
							.map((item) => QualityItemConfig.fromJson(item as Map<String, dynamic>))
							.toList()
					: null,
		);
	}
}

class QualitySectionConfig {
	final String id;
	final String label;
	final List<QualityItemConfig> objects;

	const QualitySectionConfig({
		required this.id,
		required this.label,
		required this.objects,
	});

	factory QualitySectionConfig.fromJson(Map<String, dynamic> json) {
		final rawObjects = json['objects'] ?? json['items'];
		return QualitySectionConfig(
			id: json['id'] as String,
			label: json['label'] as String,
			objects: (rawObjects as List)
					.map((item) => QualityItemConfig.fromJson(item as Map<String, dynamic>))
					.toList(),
		);
	}
}

class QualityTabConfig {
	final String id;
	final String label;
	final String type; // config | no_config
	final List<QualityItemConfig>? items;
	final List<QualitySectionConfig>? sections;

	const QualityTabConfig({
		required this.id,
		required this.label,
		required this.type,
		this.items,
		this.sections,
	}) : assert(
				(sections != null && sections.length > 0) || (items != null),
				'Quality tab must define either sections or items',
			);

	factory QualityTabConfig.fromJson(Map<String, dynamic> json) {
		final rawSections = json['sections'];
		return QualityTabConfig(
			id: json['id'] as String,
			label: json['label'] as String,
			type: json['type'] as String,
			sections: rawSections != null
					? (rawSections as List)
							.map((section) => QualitySectionConfig.fromJson(section as Map<String, dynamic>))
							.toList()
					: null,
			items: rawSections == null
					? (json['items'] as List)
							.map((item) => QualityItemConfig.fromJson(item as Map<String, dynamic>))
							.toList()
					: null,
		);
	}
}

class QualityConfig {
	final String id;
	final String name;
	final String description;

	// Used when this page has no tabs.
	final String? type; // config | no_config
	final List<QualityItemConfig>? items;
	final List<QualitySectionConfig>? sections;

	// Used when this page has tabs.
	final List<QualityTabConfig>? tabs;

	const QualityConfig({
		required this.id,
		required this.name,
		required this.description,
		this.type,
		this.items,
		this.sections,
		this.tabs,
	}) : assert(
				(tabs != null && tabs.length > 0) ||
						(sections != null && sections.length > 0) ||
						(type != null && items != null),
				'Quality page must define tabs, or sections, or root type+items',
				);

	factory QualityConfig.fromJson(Map<String, dynamic> json) {
		final rawTabs = json['tabs'];
		final rawSections = json['sections'];
		return QualityConfig(
			id: json['id'] as String,
			name: json['name'] as String,
			description: json['description'] as String,
			tabs: rawTabs != null
					? (rawTabs as List)
							.map((tab) => QualityTabConfig.fromJson(tab as Map<String, dynamic>))
							.toList()
					: null,
			sections: rawTabs == null && rawSections != null
					? (rawSections as List)
							.map((section) => QualitySectionConfig.fromJson(section as Map<String, dynamic>))
							.toList()
					: null,
			type: rawTabs == null && rawSections == null ? json['type'] as String? : null,
			items: rawTabs == null && rawSections == null
					? (json['items'] as List)
							.map((item) => QualityItemConfig.fromJson(item as Map<String, dynamic>))
							.toList()
					: null,
		);
	}
}

class QualityConfigData {
	final List<QualityConfig> qualityPages;

	const QualityConfigData({required this.qualityPages});

	factory QualityConfigData.fromJson(Map<String, dynamic> json) {
		return QualityConfigData(
			qualityPages: (json['qualityPages'] as List)
					.map((item) => QualityConfig.fromJson(item as Map<String, dynamic>))
					.toList(),
		);
	}
}
