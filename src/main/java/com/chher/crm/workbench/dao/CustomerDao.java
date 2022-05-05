package com.chher.crm.workbench.dao;

import com.chher.crm.workbench.domain.Customer;

import java.util.List;

public interface CustomerDao {

    Customer getByName(String company);

    int save(Customer customer);

    List<String> getNameList(String name);

    String getIdByName(String company);
}
