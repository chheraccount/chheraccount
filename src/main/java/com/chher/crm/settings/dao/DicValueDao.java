package com.chher.crm.settings.dao;

import com.chher.crm.settings.domain.DicValue;

import java.util.List;

public interface DicValueDao {
    List<DicValue> getByTypeCode(String codeType);
}
